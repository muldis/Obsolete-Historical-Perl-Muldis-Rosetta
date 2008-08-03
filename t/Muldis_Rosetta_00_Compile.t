use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

use version;

use Test::More;

plan( 'tests' => 8 );

use_ok( 'Muldis::Rosetta' );
is( $Muldis::Rosetta::VERSION, qv('0.8.0'),
    'Muldis::Rosetta is the correct version' );

use_ok( 'Muldis::Rosetta::Interface' );
is( $Muldis::Rosetta::Interface::VERSION, qv('0.8.0'),
    'Muldis::Rosetta::Interface is the correct version' );

use_ok( 'Muldis::Rosetta::Validator' );
is( $Muldis::Rosetta::Validator::VERSION, qv('0.8.0'),
    'Muldis::Rosetta::Validator is the correct version' );

use_ok( 'Muldis::Rosetta::Engine::Example' );
is( $Muldis::Rosetta::Engine::Example::VERSION, qv('0.8.0'),
    'Muldis::Rosetta::Engine::Example is the correct version' );

1; # Magic true value required at end of a reusable file's code.
