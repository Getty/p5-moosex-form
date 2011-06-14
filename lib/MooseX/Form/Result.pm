package MooseX::Form::Result;
# ABSTRACT: Role for result

use Moose::Role;
use MooseX::Form::TypeConstraints;
use Moose::Util qw/with_traits/;

has name => (
	is => 'ro',
	isa => 'Str',
	required => 1,
);

has submitted => (
	is => 'ro',
	isa => 'Str',
	lazy_build => 1,
);

# thoughts: a form is submitted if its param_name is set and has a true value, its purposed to be false on 0 or ""
sub _build_submitted { $_[0]->has_param_value && $_[0]->param_value ? 1 : 0 }

has valid => (
	is => 'ro',
	isa => 'Bool',
	lazy_build => 1,
);

sub _build_valid {
	my ( $self ) = @_;
	return 0 if !$self->submitted;
	my $valid = 1;
	for (@{$self->fields}) {
		$valid = 0 if !$_->valid;
	}
	return $valid;
}

has param_value => (
	is => 'ro',
	isa => 'Str',
	predicate => 'has_param_value',
);

has session => (
	is => 'ro',
	isa => 'HashRef',
	predicate => 'has_session',
);

has def => (
	is => 'ro',
	isa => 'MooseX::Form',
	required => 1,
);

has field_definitions => (
	traits  => ['Array'],
	is      => 'ro',
	isa     => 'ArrayRef[HashRef]',
	required => 1,
);

has fields => (
	traits  => ['Array'],
	is      => 'ro',
	isa     => 'ArrayRef[MooseX::Form::Result::Field]',
	lazy_build => 1,
	handles => {
		count_fields => 'count',
	},
);

sub _build_fields {
	my ( $self ) = @_;
	my @fields;
	for (@{$self->field_definitions}) {
		my $result_field_class = with_traits($self->def->form_result_field_class,@{$self->def->form_result_field_traits},@{$_->{def}->form_result_field_traits});
		push @fields, $result_field_class->new(%{$_}, form => $self);
	}
	return \@fields;
}

sub get_field {
	my ( $self, $name ) = @_;
	for (@{$self->fields}) {
		return $_ if $_->name eq $name;
	}
	return undef;
}

1;