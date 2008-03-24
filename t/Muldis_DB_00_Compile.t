use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

use version;

use Test::More;

plan( 'tests' => 10 );

use_ok( 'Muldis::DB' );
is( $Muldis::DB::VERSION, qv('0.6.2'),
    'Muldis::DB is the correct version' );

use_ok( 'Muldis::DB::Interface' );
is( $Muldis::DB::Interface::VERSION, qv('0.6.2'),
    'Muldis::DB::Interface is the correct version' );

use_ok( 'Muldis::DB::Validator' );
is( $Muldis::DB::Validator::VERSION, qv('0.6.2'),
    'Muldis::DB::Validator is the correct version' );

use_ok( 'Muldis::DB::Engine::Example::Value' );
is( $Muldis::DB::Engine::Example::Value::VERSION, qv('0.0.0'),
    'Muldis::DB::Engine::Example::Value is the correct version' );

use_ok( 'Muldis::DB::Engine::Example' );
is( $Muldis::DB::Engine::Example::VERSION, qv('0.6.2'),
    'Muldis::DB::Engine::Example is the correct version' );

1; # Magic true value required at end of a reusable file's code.
