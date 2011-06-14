package MooseX::Form::Result::Field;
# ABSTRACT: Role for a result field

use Moose::Role;
use MooseX::Form::TypeConstraints;

has name => (
	is => 'ro',
	required => 1,
	isa => 'Str',
);

has form => (
	is => 'ro',
	isa => 'MooseX::Form::Result',
#	required => 1,
);

has def => (
	is => 'ro',
	isa => 'MooseX::Form::Field',
	required => 1,
);

has value => (
	is => 'ro',
	predicate => 'has_value',
);

has attribute_value => (
	is => 'ro',
	predicate => 'has_attribute_value',
);

has param_value => (
	is => 'ro',
	isa => 'Str',
	predicate => 'has_param_value',
);

has param_values => (
	traits    => ['Hash'],
	is        => 'ro',
	isa       => 'HashRef',
	default   => sub {{}},
	handles   => {
		get_param_value => 'get',
		has_no_param_values => 'is_empty',
		num_param_values => 'count',
		param_value_pairs => 'kv',
	},
);

has messages => (
	traits  => ['Array'],
	is      => 'rw',
	isa     => 'ArrayRef',
	lazy_build => 1,
	handles => {
		count_messages => 'count',
		valid => 'is_empty',
	},
);

sub _build_messages {
	my ( $self ) = @_;
	return [] if !$self->def->field_notempty && ( !$self->has_param_value || $self->param_value eq '' );
	return [$self->def->validate_field_value($self->param_value)];
}

1;