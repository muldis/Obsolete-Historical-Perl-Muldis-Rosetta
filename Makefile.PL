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
        'namespace::clean' => 0.11,
        'Moose' => 0.80,
        'Moose::Role' => 0.80,
        'MooseX::Singleton' => 0.17,
        'Test::Moose' => 0.80,
        'Class::MOP' => 0.85, # req latest indep of Moose
    },
);

1; # Magic true value required at end of a reusable file's code.
