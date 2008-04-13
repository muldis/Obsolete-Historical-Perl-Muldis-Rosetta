use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

use Muldis::Rosetta::Validator;

Muldis::Rosetta::Validator::main({
    'engine_name' => 'Muldis::Rosetta::Engine::Example',
    'machine_config' => {},
});

1; # Magic true value required at end of a reusable file's code.
