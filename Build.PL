use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Time::Traveler',
    license             => 'perl',
    dist_author         => 'Joshua ben Jore <jjore@cpan.org>',
    dist_version_from   => 'lib/Time/Traveler.pm',
    requires => {
        'overload' => 0,
        'B' => 0,
        'Test::More' => 0,
    },
    create_makefile_pl => 'traditional',
    create_readme => 1,
    sign => 1,
    add_to_cleanup      => [ 'Time-Traveler-*' ],
);

$builder->create_build_script();
