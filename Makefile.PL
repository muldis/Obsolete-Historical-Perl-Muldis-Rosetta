use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME' => 'Muldis::Rosetta',
    'VERSION' => '0.13.3',
    'ABSTRACT' => 'Full-featured truly relational DBMS in Perl',
    'AUTHOR' => 'Darren Duncan <perl@DarrenDuncan.net>',
    'LICENSE' => 'lgpl',
    'PREREQ_PM' => {
        # These are bundled with Perls 5.10.x but not Perls 5.8.x.
        'version' => 0.74,
        # These are not bundled with any version of Perl.
        'namespace::autoclean' => 0.08,
        'Moose' => 0.87,
        'Moose::Role' => 0.87,
        'MooseX::Singleton' => 0.18,
        'Class::MOP' => 0.89, # req latest indep of Moose
        # These r only used by Validator / th tests, are n bndl w any Perl.
        'Test::More' => 0.88, # but upd later to v that perl 5.10.1 bundles
        'Test::Moose' => 0.87,
        'Carp::Always' => 0.09,
    },
);

1; # Magic true value required at end of a reusable file's code.
