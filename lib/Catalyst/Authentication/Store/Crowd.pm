package Catalyst::Authentication::Store::Crowd;

use warnings;
use Moose;

use LWP::UserAgent;
use HTTP::Request;
use JSON;

use Catalyst::Authentication::Store::Crowd::User;


has 'find_user_url' => (
    is => 'ro',
    isa => 'Str',
    required => '1',
    default => sub {
        'https://crowd.startsiden.no/crowd/rest/usermanagement/latest/user';
    }
);

has 'app' => (
    is => 'ro',
    isa => 'HashRef',
    required => '1',
    default => sub { {} }
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my $init_hash = {};
    $init_hash->{find_user_url} = $_[0]->{find_user_url} if defined $_[0]->{find_user_url};
    $init_hash->{app} = $_[0]->{app} if defined $_[0]->{app};
    return $class->$orig( %$init_hash );
};

sub find_user {
    my ($self, $authinfo) = @_;
    my $crowd_user = $self->_crowd_get_user( $authinfo->{username} );
    return Catalyst::Authentication::Store::Crowd::User->new(
        $crowd_user
    );
}

sub from_session {
    my ( $self, $c, $user ) = @_;
    return $user;
}

sub for_session {
    my ( $self, $c, $user ) = @_;
    return $user;
}

sub _crowd_get_user {
    my ( $self, $username ) = @_;
    my $ua = LWP::UserAgent->new('Startsiden Frontpage Admin Client');
    my $uri = $self->find_user_url."?username=$username";
    my $req = HTTP::Request->new( 'GET',  $uri );
    $req->authorization_basic(
        $self->app->{app_name},
        $self->app->{password}
    );
    $req->header('Accept' => 'application/json');

    my $response = $ua->request( $req );
    my $json_hash = from_json( $response->decoded_content );
    $json_hash->{active} = $json_hash->{active} ? 1 : 0;
    return $self->_replace_dash_in_keys( $json_hash );
}

sub _replace_dash_in_keys {
    my ($self, $json_data) = @_;
    foreach my $key ( keys %$json_data ){
        if ( $key =~ m/\-/ ){
            # replace - with _
            my $new_key = $key;
            $new_key =~ s/\-/_/g;
            # delete old key and make new key
            $json_data->{$new_key} = $json_data->{$key};
            delete $json_data->{$key};
        }
    }
    return $json_data;
}

1;

__END__

=head1 NAME

Catalyst::Authentication::Credential::Crowd - Authenticate a user using Crowd REST Service

=head1 SYNOPSIS

    use Catalyst qw/
        Authentication

    /;

    __PACKAGE__->config( authentication => {
        default_realm => 'crowd',
        realms => {
            crowd => {
                credential => {
                    class => 'Crowd',
                    service_url => 'http://yourcrowdservice.url/authentication,
                    app => {
                        app_name => 'your_crowd_app_name',
                        password => 'password_for_app_name',
                    }
                },
                store => ...
            },
        }
    });

    # in controller

    sub login : Local {
        my ( $self, $c ) = @_;

        $c->authenticate( {
            username => $c->req->param('username'),
            password => $c->req->param('password')
        }

        # ... do something else ...
    }

=head1 METHODS

=head2 authenticate

Authenticate a user. This method is called from context object Ex. $c->authenticate


=head1 PRIVATE METHODS

=head2 _crowd_authen

Make a HTTP request to Crowd REST Service to authenticate a user.


=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Keerati Thiwanruk, E<lt>keerati.th@gmail.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Keerati Thiwanruk

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
