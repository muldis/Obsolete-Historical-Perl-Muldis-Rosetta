use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME' => 'Muldis::Rosetta',
    'VERSION' => '0.14.0',
    'ABSTRACT' => 'Full-featured truly relational DBMS in Perl',
    'AUTHOR' => 'Darren Duncan <perl@DarrenDuncan.net>',
    'LICENSE' => 'lgpl',
    'PREREQ_PM' => {
        # ALWAYS REQUIRES:

        # These are not bundled with any version of Perl.
        'namespace::autoclean' => 0.08,
        'Moose' => 0.89,
        'Moose::Role' => 0.89,
        'MooseX::Singleton' => 0.18,
        'Class::MOP' => 0.92, # req latest indep of Moose

        # VALIDATOR MODULE REQUIRES:

        # These are bundled with Perls 5.10.1+ but not earlier Perls.
        'Test::More' => 0.92,
        # These are not bundled with any version of Perl.
        'Test::Moose' => 0.89,

        # BUILD REQUIRES:

        # These are not bundled with any version of Perl.
        'Carp::Always' => 0.09,
    },
);

1; # Magic true value required at end of a reusable file's code.
