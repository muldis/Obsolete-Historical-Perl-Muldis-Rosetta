use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME' => 'Muldis::Rosetta',
    'VERSION' => '0.12.0',
    'ABSTRACT' => 'Full-featured truly relational DBMS in Perl',
    'AUTHOR' => 'Darren Duncan <perl@DarrenDuncan.net>',
    'LICENSE' => 'lgpl',
    'PREREQ_PM' => {
        # These are bundled with Perls 5.10.x but not Perls 5.8.x.
        'version' => 0.74,
        # Bundled w Perls 5.10.1+,5.8.9+ but n earlier Perls 5.10.0,5.8.x.
        'autodie' => 1.994,
        # These are not bundled with any version of Perl.
        'Moose' => 0.59,
        'Moose::Role' => 0.59,
        'MooseX::Singleton' => 0.12,
        'Test::Moose' => 0.59,
    },
);

1; # Magic true value required at end of a reusable file's code.
