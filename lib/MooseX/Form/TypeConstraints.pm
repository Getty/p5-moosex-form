package MooseX::Form::TypeConstraints;
# ABSTRACT: TypeConstraints used by MooseX::Form

use Moose::Util::TypeConstraints;

role_type "MooseX::Form";
role_type "MooseX::Form::Field";

1;