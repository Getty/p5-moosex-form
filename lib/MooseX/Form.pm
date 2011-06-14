package MooseX::Form;
# ABSTRACT: Get forms from your Moose classes

use Moose::Role;
use MooseX::Form::TypeConstraints;
use MooseX::Form::Result;
use MooseX::Form::Result::Field;
use Moose::Util qw/with_traits/;

has form_param => (
	is => 'ro',
	isa => 'Str',
	lazy_build => 1,
);

sub _build_form_param {
	my ( $self ) = @_;
	my $class = lc(ref $self);
	$class =~ s/::/_/g;
	return $class.($self->form_id);
}

has form_id => (
	is => 'ro',
	isa => 'Str',
	lazy_build => 1,
);

sub _build_form_id {
	my ( $self ) = @_;
	return $self->id if ($self->can('id'));
	return "";
}

has form_fields => (
	traits  => ['Array'],
	is => 'ro',
	isa => 'ArrayRef[MooseX::Form::Field]',
	lazy_build => 1,
	handles => {
		all_form_fields => 'elements',
		map_form_fields => 'map',
		filter_form_fields => 'grep',
		count_form_fields => 'count',
		has_no_form_fields => 'is_empty',
		sorted_form_fields => 'sort',
	},
);

sub _build_form_fields {
	my ( $self ) = @_;

	my @fields;
	
	for (sort { $a->insertion_order <=> $b->insertion_order } $self->meta->get_all_attributes) {
		if ($_->does('MooseX::Form::Field')) {
			push @fields, $_;
		}
	}

	return \@fields;
}

has form_result_traits => (
	is => 'ro',
	isa => 'ArrayRef[Str]',
	default => sub {[]},
);

sub form_result_field_traits { ['MooseX::Form::Result::Field'] }

sub form_result_class { 'Moose::Object' }
sub form_result_field_class { 'Moose::Object' }

sub param_join_string { '_' }

has form_result_traits => (
	is => 'ro',
	isa => 'ArrayRef[Str]',
	default => sub {['MooseX::Form::Result']},
);

sub form {
	my $self = shift;
	
	my %args = ref $_[0] ne 'HASH' ? @_ : %{$_[0]};
	my %p = %{$args{params}};
	
	my %form;
	
	$form{name} = $self->form_param;

	if ($args{session}) {
		$args{session}->{"form_".$self->form_param} = {
			fields => {},
		} if (!defined $args{session}->{"form_".$self->form_param});
		$form{session} = $args{session}->{"form_".$self->form_param};
	}

	$form{param_value} = $p{$form{name}} if defined $p{$form{name}};
	$form{def} = $self;
	
	for (@{$self->form_fields}) {

		my %field;
		
		$field{name} = $_->name;
		
		if (defined $form{session}) {
			$form{session}->{fields}->{$_->name} = {};
			$field{session} = $form{session}->{fields}->{$_->name};
		}

		my $field_param = $self->form_param.$self->param_join_string.$_->name;
		my $field_param_prefix = $self->form_param.$self->param_join_string.$_->name.$self->param_join_string;
		for (keys %p) {
			$field{param_values}->{$1} = $p{$_} if $_ =~ /^$field_param_prefix(.*)/;
			$field{param_value} = $p{$_} if $_ eq $field_param;
		}

		$field{def} = $_;
		
		push @{$form{field_definitions}}, \%field;
	}

	my $result_class = with_traits($self->form_result_class,@{$self->form_result_traits});

	return $result_class->new(\%form);
}

sub _form_prepare {
	my ( $self, $p, $s ) = @_;
}

1;
