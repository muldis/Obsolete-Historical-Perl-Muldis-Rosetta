use 5.008003;
use utf8;
use strict;
use warnings;

use ExtUtils::MakeMaker;

# Make setting optional MakeMaker parameters more readable.
sub OPTIONAL {
   return () unless $ExtUtils::MakeMaker::VERSION ge shift;
   return @_;
}

WriteMakefile(
   NAME => 'Muldis::Rosetta',
   VERSION => '0.16.0',
   ABSTRACT => 'Full-featured truly relational DBMS in Perl',
   AUTHOR => 'Darren Duncan <darren@DarrenDuncan.net>',
   PREREQ_PM => {
      # This list is a copy of "META_ADD:[configure_|build_|]requires"
      # where the other is canonical; this list is for use by MakeMaker
      # itself, which in general wouldn't see the info in the other lists,
      # as the other lists are primarily used when generating the META.yml.
      'Carp::Always' => '0.09',
      'Class::MOP' => '2.0000',
      'ExtUtils::MakeMaker' => '6.48',
      'Moose' => '2.0000',
      'Moose::Role' => '2.0000',
      'MooseX::Singleton' => '0.27',
      'namespace::autoclean' => '0.12',
      'Test::Moose' => '2.0000',
      'Test::More' => '0.94',
      'Try::Tiny' => '0.09',
   },
   OPTIONAL( '6.48',
      MIN_PERL_VERSION => '5.008003',
   ),
   OPTIONAL( '6.31',
      LICENSE => 'lgpl_3',
   ),
   OPTIONAL( '6.46',
      # Use META_ADD instead of META_MERGE so that we can remove
      # any build-time dependencies that MakeMaker will put into
      # the requires field.  (Comment From DBD::SQLite; do *we* need that?)
      META_ADD => {
         configure_requires => {
            'ExtUtils::MakeMaker' => '6.48',
         },
         build_requires => {
            'ExtUtils::MakeMaker' => '6.48',
            # These are bundled with Perls 5.12.0+ but not earlier Perls.
            'Test::More' => '0.94',
            # These are not bundled with any version of Perl.
            'Carp::Always' => '0.09',
         },
         requires => {
            # ALWAYS REQUIRES:

            'perl' => '5.008003', # as MIN_PERL_VERSION no affect META.yml
            # These are not bundled with any version of Perl.
            'Class::MOP' => '2.0000',
            'Moose' => '2.0000',
            'Moose::Role' => '2.0000',
            'MooseX::Singleton' => '0.27',
            'namespace::autoclean' => '0.12',
            'Try::Tiny' => '0.09',

            # VALIDATOR MODULE REQUIRES:

            # These are bundled with Perls 5.12.0+ but not earlier Perls.
            'Test::More' => '0.94',
            # These are not bundled with any version of Perl.
            'Test::Moose' => '2.0000',
         },
         resources => {
            homepage => 'http://www.muldis.com/',
            license => 'http://www.fsf.org/licensing/licenses/lgpl.html',
            MailingList => 'http://mm.darrenduncan.net/mailman/listinfo',
            repository => 'http://github.com/muldis/Muldis-Rosetta',
         },
      },
   ),
);

1;
