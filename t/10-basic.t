#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

{
	package Bigger;
	use Moose;
	
	with qw(
		MooseX::Form
	);
	
	has name => (
		traits => ['MooseX::Form::Field'],
		is => 'rw',
		isa => 'Str',
	);

	has desc => (
		traits => ['MooseX::Form::Field'],
		is => 'rw',
		isa => 'Str',
	);

	has score => (
		traits => ['MooseX::Form::Field'],
		is => 'rw',
		isa => 'Num',
	);

}

my $desc_testvalue = 'No description given';
my $form = Bigger->new( desc => $desc_testvalue );

isa_ok($form,'Bigger');
is($form->form_param,'bigger','Auto form_param is set proper');
is($form->form_id,'','Auto form_id is set proper');

my $session = {
	session_id => 123456,
};

my $form_result = $form->form({
	params => {
		bigger => 1,
		bigger_name => 'value_name',
		bigger_name_color => 'value_name_color',
		bigger_desc => 'value_desc',
		bigger_score_idea => 'value_idea',
	},
	session => $session,
});

ok($form_result->submitted,'Form is submitted');
ok($form_result->valid,'Form is valid');

is_deeply($session->{form_bigger}->{fields}->{name},{},"name field of form has proper sesssion content");
is_deeply($session->{form_bigger}->{fields}->{desc},{},"desc field of form has proper sesssion content");
is_deeply($session->{form_bigger}->{fields}->{score},{},"score field of form has proper sesssion content");

is($form_result->get_field('name')->form,$form_result,'field reference to proper form result');
is($form_result->get_field('desc')->attribute_value,$desc_testvalue,"attribute value reached field");

done_testing;