use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

use version 0.74;

use Test::More;

plan( 'tests' => 24 );

use_ok( 'Muldis::Rosetta' );
is( $Muldis::Rosetta::VERSION, qv('0.11.1'),
    'Muldis::Rosetta is the correct version' );

use_ok( 'Muldis::Rosetta::Interface' );
is( $Muldis::Rosetta::Interface::VERSION, qv('0.11.1'),
    'Muldis::Rosetta::Interface is the correct version' );

use_ok( 'Muldis::Rosetta::Validator' );
is( $Muldis::Rosetta::Validator::VERSION, qv('0.11.1'),
    'Muldis::Rosetta::Validator is the correct version' );

use_ok( 'Muldis::Rosetta::Util::Tiny' );
is( $Muldis::Rosetta::Util::Tiny::VERSION, qv('0.0.0'),
    'Muldis::Rosetta::Util::Tiny is the correct version' );

use_ok( 'Muldis::Rosetta::Engine::Example::Value' );
is( $Muldis::Rosetta::Engine::Example::Value::VERSION, qv('0.0.0'),
    'Muldis::Rosetta::Engine::Example::Value is the correct version' );

use_ok( 'Muldis::Rosetta::Engine::Example::Routines' );
is( $Muldis::Rosetta::Engine::Example::Routines::VERSION, qv('0.0.0'),
    'Muldis::Rosetta::Engine::Example::Routines is the correct version' );

use_ok( 'Muldis::Rosetta::Engine::Example::Storage' );
is( $Muldis::Rosetta::Engine::Example::Storage::VERSION, qv('0.0.0'),
    'Muldis::Rosetta::Engine::Example::Storage is the correct version' );

use_ok( 'Muldis::Rosetta::Engine::Example::Runtime' );
is( $Muldis::Rosetta::Engine::Example::Runtime::VERSION, qv('0.0.0'),
    'Muldis::Rosetta::Engine::Example::Runtime is the correct version' );

use_ok( 'Muldis::Rosetta::Engine::Example::Util' );
is( $Muldis::Rosetta::Engine::Example::Util::VERSION, qv('0.0.0'),
    'Muldis::Rosetta::Engine::Example::Util is the correct version' );

use_ok( 'Muldis::Rosetta::Engine::Example::PlainText' );
is( $Muldis::Rosetta::Engine::Example::PlainText::VERSION, qv('0.0.0'),
    'Muldis::Rosetta::Engine::Example::PlainText is the correct version' );

use_ok( 'Muldis::Rosetta::Engine::Example::HostedData' );
is( $Muldis::Rosetta::Engine::Example::HostedData::VERSION, qv('0.0.0'),
    'Muldis::Rosetta::Engine::Example::HostedData'
    . ' is the correct version' );

use_ok( 'Muldis::Rosetta::Engine::Example' );
is( $Muldis::Rosetta::Engine::Example::VERSION, qv('0.11.1'),
    'Muldis::Rosetta::Engine::Example is the correct version' );

1; # Magic true value required at end of a reusable file's code.
