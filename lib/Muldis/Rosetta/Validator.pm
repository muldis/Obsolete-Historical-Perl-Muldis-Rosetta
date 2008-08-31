use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

use Muldis::Rosetta::Interface 0.011000;

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Validator; # module
    use version 0.74; our $VERSION = qv('0.11.0');

    use Test::More;

###########################################################################

sub main {
    my ($args) = @_;
    my ($engine_name, $machine_config, $process_config)
        = @{$args}{'engine_name', 'machine_config', 'process_config'};

    plan( 'tests' => 13 );

    print "#### Muldis::Rosetta::Validator"
        . " starting test of $engine_name ####\n";

    # Instantiate a Muldis Rosetta DBMS / virtual machine.
    my $machine = Muldis::Rosetta::Interface::new_machine({
        'engine_name' => $engine_name,
        'machine_config' => $machine_config,
    });
    does_ok( $machine, 'Muldis::Rosetta::Interface::Machine' );
    my $process = $machine->new_process({
        'process_config' => $process_config,
    });
    does_ok( $process, 'Muldis::Rosetta::Interface::Process' );
    $process->update_hd_command_lang({ 'lang' => [ 'Muldis_D',
        'http://muldis.com', '0.47.0', 'HDMD_Perl_Tiny', {} ] });

    _scenario_foods_suppliers_shipments_v1( $process );

    print "#### Muldis::Rosetta::Validator"
        . " finished test of $engine_name ####\n";

    return;
}

###########################################################################

sub _scenario_foods_suppliers_shipments_v1 {
    my ($process) = @_;

    # Declare our example literal source data sets.

    my $src_suppliers = $process->new_value({
        'source_code' => [ 'Relation', [ 'farm', 'country', ], [
            [ [ 'Text', 'Hodgesons' ], [ 'Text', 'Canada'  ], ],
            [ [ 'Text', 'Beckers'   ], [ 'Text', 'England' ], ],
            [ [ 'Text', 'Wickets'   ], [ 'Text', 'Canada'  ], ],
        ] ],
    });
    pass( 'no death from loading example suppliers data into VM' );
    does_ok( $src_suppliers, 'Muldis::Rosetta::Interface::Value' );

    my $src_foods = $process->new_value({
        'source_code' => [ 'Relation', [ 'food', 'colour', ], [
            [ [ 'Text', 'Bananas' ], [ 'Text', 'yellow' ], ],
            [ [ 'Text', 'Carrots' ], [ 'Text', 'orange' ], ],
            [ [ 'Text', 'Oranges' ], [ 'Text', 'orange' ], ],
            [ [ 'Text', 'Kiwis'   ], [ 'Text', 'green'  ], ],
            [ [ 'Text', 'Lemons'  ], [ 'Text', 'yellow' ], ],
        ] ],
    });
    pass( 'no death from loading example foods data into VM' );
    does_ok( $src_foods, 'Muldis::Rosetta::Interface::Value' );

    my $src_shipments = $process->new_value({
        'source_code' => [ 'Relation', [
            {
                'farm' => [ 'Text', 'Hodgesons' ],
                'food' => [ 'Text', 'Kiwis' ],
                'qty'  => [ 'Int', 'perl_int', 100 ],
            },
            {
                'farm' => [ 'Text', 'Hodgesons' ],
                'food' => [ 'Text', 'Lemons' ],
                'qty'  => [ 'Int', 'perl_int', 130 ],
            },
            {
                'farm' => [ 'Text', 'Hodgesons' ],
                'food' => [ 'Text', 'Oranges' ],
                'qty'  => [ 'Int', 'perl_int', 10 ],
            },
            {
                'farm' => [ 'Text', 'Hodgesons' ],
                'food' => [ 'Text', 'Carrots' ],
                'qty'  => [ 'Int', 'perl_int', 50 ],
            },
            {
                'farm' => [ 'Text', 'Beckers' ],
                'food' => [ 'Text', 'Carrots' ],
                'qty'  => [ 'Int', 'perl_int', 90 ],
            },
            {
                'farm' => [ 'Text', 'Beckers' ],
                'food' => [ 'Text', 'Bananas' ],
                'qty'  => [ 'Int', 'perl_int', 120 ],
            },
            {
                'farm' => [ 'Text', 'Wickets' ],
                'food' => [ 'Text', 'Lemons' ],
                'qty'  => [ 'Int', 'perl_int', 30 ],
            },
        ] ],
    });
    pass( 'no death from loading example shipments data into VM' );
    does_ok( $src_shipments, 'Muldis::Rosetta::Interface::Value' );

    # Execute a query against the virtual machine, to look at our sample
    # data and see what suppliers there are for foods coloured 'orange'.

    my $desi_colour = $process->new_value({
        'source_code' => [ 'Text', 'orange' ] });
    pass( 'no death from loading desired colour into VM' );
    does_ok( $desi_colour, 'Muldis::Rosetta::Interface::Value' );

    my $matched_suppl = $process->func_invo({
        'function' => 'sys.std.Core.Relation.semijoin',
        'args' => {
            'source' => $src_suppliers,
            'filter' => $process->func_invo({
                'function' => 'sys.std.Core.Relation.join',
                'args' => {
                    'topic' => [ 'QuasiSet', [
                        $src_shipments,
                        $src_foods,
                        [ 'Relation', [ { 'colour' => $desi_colour } ] ],
                    ] ],
                },
            }),
        },
    });
    pass( 'no death from executing search query' );
    does_ok( $matched_suppl, 'Muldis::Rosetta::Interface::Value' );

    my $matched_suppl_as_perl = $matched_suppl->hd_source_code();
    pass( 'no death from fetching search results from VM' );

    # Finally, use the result somehow (not done here).
    # The result should be:
    # [ 'Relation', [ 'farm', 'country', ], [
    #     [ [ 'Text', 'Hodgesons' ], [ 'Text', 'Canada'  ], ],
    #     [ [ 'Text', 'Beckers'   ], [ 'Text', 'England' ], ],
    # ] ],

    print "# debug: orange food suppliers found:\n";
#    print "# " . $matched_suppl_as_perl->as_perl() . "\n";
    print "#  TODO, as_perl()\n";

    return;
}

###########################################################################

# Modified clone of isa_ok from Test::More,
# since we actually want to test with does() rather than isa();
# it is identical to the original save the s/isa/does/g and s/class/role/g;
# this will probably be replaced later with something simple.

sub does_ok ($$;$) {
    my($object, $role, $obj_name) = @_;
    my $tb = Test::More->builder;
    my $diag;
    $obj_name = 'The object' unless defined $obj_name;
    my $name = "$obj_name does $role";
    if( !defined $object ) {
        $diag = "$obj_name isn't defined";
    }
    elsif( !ref $object ) {
        $diag = "$obj_name isn't a reference";
    }
    else {
        # We can't use UNIVERSAL::does because we want to honor does() overrides
        my($rslt, $error) = $tb->_try(sub { $object->does($role) });
        if( $error ) {
            if( $error =~ /^Can't call method "does" on unblessed reference/ ) {
                # Its an unblessed reference
                if( !UNIVERSAL::does($object, $role) ) {
                    my $ref = ref $object;
                    $diag = "$obj_name isn't a '$role' it's a '$ref'";
                }
            } else {
                die <<WHOA;
WHOA! I tried to call ->does on your object and got some weird error.
Here's the error.
$error
WHOA
            }
        }
        elsif( !$rslt ) {
            my $ref = ref $object;
            $diag = "$obj_name isn't a '$role' it's a '$ref'";
        }
    }
    my $ok;
    if( $diag ) {
        $ok = $tb->ok( 0, $name );
        $tb->diag("    $diag\n");
    }
    else {
        $ok = $tb->ok( 1, $name );
    }
    return $ok;
}

###########################################################################

} # module Muldis::Rosetta::Validator

###########################################################################
###########################################################################

1; # Magic true value required at end of a reusable file's code.
__END__

=pod

=encoding utf8

=head1 NAME

Muldis::Rosetta::Validator -
A common comprehensive test suite to run against all Engines

=head1 VERSION

This document describes Muldis::Rosetta::Validator version 0.11.0 for Perl
5.

=head1 SYNOPSIS

This can be the complete content of the main C<t/*.t> file for an example
Muldis Rosetta Engine distribution:

    use 5.008001;
    use utf8;
    use strict;
    use warnings FATAL => 'all';

    # Load the test suite.
    use Muldis::Rosetta::Validator;

    # Run the test suite.
    Muldis::Rosetta::Validator::main({
        'engine_name' => 'Muldis::Rosetta::Engine::Example',
        'machine_config' => {},
    });

    1;

The current release of Muldis::Rosetta::Validator uses L<Test::More>
internally, and C<main()> will invoke it to output what the standard Perl
test harness expects.  I<It is expected that this will change in the future
so that Validator does not use Test::More internally, and rather will
simply return test results in a data structure that the main t/*.t then can
disseminate and pass the components to Test::More itself.>

=head1 DESCRIPTION

The Muldis::Rosetta::Validator Perl 5 module is a common comprehensive test
suite to run against all Muldis Rosetta Engines.  You run it against a
Muldis Rosetta Engine module to ensure that the Engine and/or the database
behind it implements the parts of the Muldis Rosetta API that your
application needs, and that the API is implemented correctly.
Muldis::Rosetta::Validator is intended to guarantee a measure of quality
assurance (QA) for Muldis::Rosetta, so your application can use the
database access framework with confidence of safety.

Alternately, if you are writing a Muldis Rosetta Engine module yourself,
Muldis::Rosetta::Validator saves you the work of having to write your own
test suite for it.  You can also be assured that if your module passes
Muldis::Rosetta::Validator's approval, then your module can be easily
swapped in for other Engine modules by your users, and that any changes you
make between releases haven't broken something important.

Muldis::Rosetta::Validator would be used similarly to how Sun has an
official validation suite for Java Virtual Machines to make sure they
implement the official Java specification.

For reference and context, please see the FEATURE SUPPORT VALIDATION
documentation section in the core L<Muldis::Rosetta> module.

Note that, as is the nature of test suites, Muldis::Rosetta::Validator will
be getting regular updates and additions, so that it anticipates all of the
different ways that people want to use their databases.  This task is
unlikely to ever be finished, given the seemingly infinite size of the
task.  You are welcome and encouraged to submit more tests to be included
in this suite at any time, as holes in coverage are discovered.

I<This documentation is pending.>

=head1 INTERFACE

I<This documentation is pending; this section may also be split into
several.>

=head1 DIAGNOSTICS

I<This documentation is pending.>

=head1 CONFIGURATION AND ENVIRONMENT

I<This documentation is pending.>

=head1 DEPENDENCIES

This file requires any version of Perl 5.x.y that is at least 5.8.1, and
recommends one that is at least 5.10.0.

It also requires these Perl 5 packages that are bundled with any version of
Perl 5.x.y that is at least 5.10.0, and are also on CPAN for separate
installation by users of earlier Perl versions: L<version>.

It also requires these Perl 5 classes that are in the current distribution:
L<Muldis::Rosetta::Interface-0.11.0|Muldis::Rosetta::Interface>.

=head1 INCOMPATIBILITIES

None reported.

=head1 SEE ALSO

Go to L<Muldis::Rosetta> for the majority of distribution-internal
references, and L<Muldis::Rosetta::SeeAlso> for the majority of
distribution-external references.

=head1 BUGS AND LIMITATIONS

I<This documentation is pending.>

=head1 AUTHOR

Darren Duncan (C<perl@DarrenDuncan.net>)

=head1 LICENSE AND COPYRIGHT

This file is part of the Muldis Rosetta framework.

Muldis Rosetta is Copyright © 2002-2008, Darren Duncan.

See the LICENSE AND COPYRIGHT of L<Muldis::Rosetta> for details.

=head1 TRADEMARK POLICY

The TRADEMARK POLICY in L<Muldis::Rosetta> applies to this file too.

=head1 ACKNOWLEDGEMENTS

The ACKNOWLEDGEMENTS in L<Muldis::Rosetta> apply to this file too.

=cut
