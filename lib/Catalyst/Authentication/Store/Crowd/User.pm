package Startsiden::Frontpage::Admin::Authentication::Store::Crowd::User;

use warnings;

use Moose;
extends 'Catalyst::Authentication::User';

has 'name' => ( is => 'ro', isa => 'Str' );
has 'display_name' => ( is => 'ro', isa => 'Str' );
has 'email' => ( is => 'ro', isa => 'Str' );
has 'first_name' => ( is => 'ro', isa => 'Str' );
has 'last_name' => ( is => 'ro', isa => 'Str' );
has 'active' => ( is => 'ro', isa => 'Bool' );

sub supported_features {
    return { session => 1 };
}

1;
