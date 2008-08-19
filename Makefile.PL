use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

warn q{
---------------------------------------------------------------------------
  NOTE: Please ignore any warnings during installation about the use of
  "=encoding utf8" in the pod documentation.

  Continuing in 3 seconds...
---------------------------------------------------------------------------
};
sleep 3;

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME' => 'Muldis::Rosetta',
    'VERSION' => '0.10.0',
    'ABSTRACT' => 'Full-featured truly relational DBMS in Perl',
    'AUTHOR' => 'Darren Duncan <perl@DarrenDuncan.net>',
    'LICENSE' => 'lgpl',
    'PREREQ_PM' => {
        # These are bundled with Perls 5.10.x but not Perls 5.8.x.
        'version' => 0.74,
        # These are not bundled with any version of Perl.
        'Moose' => 0.55,
        'Moose::Role' => 0.55,
    },
);

1; # Magic true value required at end of a reusable file's code.
