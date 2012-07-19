use inc::Module::Install 0.65;

name 'Catalyst-Authentication-Store-Crowd';
all_from 'lib/Catalyst/Authentication/Store/Crowd.pm';

requires 'Moose';
requires 'Catalyst::Runtime';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Authentication::User';
requires 'HTTP::Request';
requires 'LWP::UserAgent';
requires 'JSON';

test_requires 'Test::More';
test_requires 'Test::Fake::HTTPD';

auto_install;
WriteAll;
