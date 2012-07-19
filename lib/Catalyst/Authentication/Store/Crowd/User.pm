package Catalyst::Authentication::Store::Crowd::User;

use Moose;
extends 'Catalyst::Authentication::User';

has 'info' => ( is => 'ro', isa => 'HashRef' );

sub supports {
    return { session => 1 };
}

1;
