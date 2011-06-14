package MooseX::Form::Field;
# ABSTRACT: base role for form fields

use Moose::Role;
use Try::Tiny;

requires 'name';

has field_notempty => (
	is => 'ro',
	isa => 'Bool',
	default => sub { 0 },
);

has form_result_field_traits => (
	is => 'ro',
	isa => 'ArrayRef[Str]',
	default => sub {[]},
);

sub validate_field_value {
	my ( $self, $value ) = @_;
	die "MooseX::Form::Field default validation requires 'verify_against_type_constraint'" if !$self->can('verify_against_type_constraint');
	my @messages;
	try {
		$self->verify_against_type_constraint($value);
	} catch {
		push @messages, $_;
	}
	return @messages;
}

1;