use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Interface; # module
    use version 0.74; our $VERSION = qv('0.11.0');
    # Note: This given version applies to all of this file's packages.

    use Carp;
    use Encode qw(is_utf8);
    use Scalar::Util qw(blessed);

###########################################################################

sub new_machine {
    my ($args) = @_;
    my ($engine_name, $machine_config)
        = @{$args}{'engine_name', 'machine_config'};

    confess q{new_machine(): Bad :$engine_name arg; Perl 5 does not}
            . q{ consider it to be a character str, or it's the empty str.}
        if !defined $engine_name or $engine_name eq q{}
            or (!is_utf8 $engine_name
                and $engine_name =~ m/[^\x00-\x7F]/xs);
            # TODO: also use some Encode::foo to check that the actual byte
            # sequences are valid utf-8, in case the text value came from
            # some bad source that just flipped the is_utf8 flag without
            # actually first making the string valid utf8.

    # A module may be loaded due to it being embedded in a non-excl file.
    if (!do {
            no strict 'refs';
            defined %{$engine_name . '::'};
        }) {
        # Note: We have to invoke this 'require' in an eval string
        # because we need the bareword semantics, where 'require'
        # will munge the module name into file system paths.
        eval "require $engine_name;";
        if (my $err = $@) {
            confess q{new_machine(): Could not load Muldis Rosetta Engine}
                . qq{ module '$engine_name': $err};
        }
        confess qq{new_machine(): Could not load Muldis Rosetta Engine mod}
                . qq{ '$engine_name': while that file did compile without}
                . q{ errors, it did not declare the same-named module.}
            if !do {
                no strict 'refs';
                defined %{$engine_name . '::'};
            };
    }
    confess qq{new_machine(): The Muldis Rosetta Engine mod '$engine_name'}
            . q{ does not provide the new_machine() constructor function.}
        if !$engine_name->can( 'new_machine' );
    my $machine = eval {
        &{$engine_name->can( 'new_machine' )}({
            'machine_config' => $machine_config });
    };
    if (my $err = $@) {
        confess qq{new_machine(): Th Muldis Rosetta Eng mod '$engine_name'}
            . qq{ threw an exception during its new_machine() exec: $err};
    }
    confess q{new_machine(): The new_machine() constructor function of the}
            . qq{ Muldis Rosetta Engine mod '$engine_name' did not ret an}
            . q{ obj of a Muldis::Rosetta::Interface::Machine-doing class.}
        if !blessed $machine or !$machine->isa( 'Moose::Object' )
            or !$machine->does( 'Muldis::Rosetta::Interface::Machine' );

    return $machine;
}

###########################################################################

} # module Muldis::Rosetta::Interface

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Interface::Machine; # role
    use Moose::Role;

    requires 'new_process';

} # role Muldis::Rosetta::Interface::Machine

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Interface::Process; # role
    use Moose::Role;

    requires 'assoc_machine';
    requires 'pt_command_lang';
    requires 'update_pt_command_lang';
    requires 'hd_command_lang';
    requires 'update_hd_command_lang';
    requires 'execute';
    requires 'new_value';
    requires 'func_invo';
    requires 'upd_invo';
    requires 'proc_invo';
    requires 'trans_nest_level';
    requires 'start_trans';
    requires 'commit_trans';
    requires 'rollback_trans';

} # role Muldis::Rosetta::Interface::Process

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Interface::Value; # role
    use Moose::Role;

    requires 'assoc_process';
    requires 'pt_source_code';
    requires 'hd_source_code';

} # role Muldis::Rosetta::Interface::Value

###########################################################################
###########################################################################

1; # Magic true value required at end of a reusable file's code.
__END__

=pod

=encoding utf8

=head1 NAME

Muldis::Rosetta::Interface -
Common public API for Muldis Rosetta Engines

=head1 VERSION

This document describes Muldis::Rosetta::Interface version 0.11.0 for Perl
5.

It also describes the same-number versions for Perl 5 of
Muldis::Rosetta::Interface::Machine ("Machine"),
Muldis::Rosetta::Interface::Process ("Process"),
Muldis::Rosetta::Interface::Value ("Value").

=head1 SYNOPSIS

This simple example declares two Perl variables containing relation data,
then does a (N-ary) relational join (natural inner join) on them, producing
a third Perl variable holding the relation data of the result.

    use Muldis::Rosetta::Interface;

    my $machine = Muldis::Rosetta::Interface::new_machine({
        'engine_name' => 'Muldis::Rosetta::Engine::Example' });
    my $process = $machine->new_process();
    $process->update_hd_command_lang({ 'lang' => [ 'Muldis_D',
        'http://muldis.com', '0.47.0', 'HDMD_Perl_Tiny', {} ] });

    my $r1 = $process->new_value({
        'source_code' => [ 'Relation', [ 'x', 'y', ], [
            [ [ 'Int', 'perl_int', 4 ], [ 'Int', 'perl_int', 7 ], ],
            [ [ 'Int', 'perl_int', 3 ], [ 'Int', 'perl_int', 2 ], ],
        ] ]
    });

    my $r2 = $process->new_value({
        'source_code' => [ 'Relation', [ 'y', 'z', ], [
            [ [ 'Int', 'perl_int', 5 ], [ 'Int', 'perl_int', 6 ], ],
            [ [ 'Int', 'perl_int', 2 ], [ 'Int', 'perl_int', 1 ], ],
            [ [ 'Int', 'perl_int', 2 ], [ 'Int', 'perl_int', 4 ], ],
        ] ]
    });

    my $r3 = $process->func_invo({
        'function' => 'sys.std.Core.Relation.join',
        'args' => {
            'topic' => [ 'QuasiSet', [ $r1, $r2 ] ],
        }
    });

    my $r3_as_perl = $r3->hd_source_code();

    # Then $r3_as_perl contains:
    # [ 'Relation', [
    #     {
    #         'x' => [ 'Int', 'perl_int', 3 ],
    #         'y' => [ 'Int', 'perl_int', 2 ],
    #         'z' => [ 'Int', 'perl_int', 1 ],
    #     },
    #     {
    #         'x' => [ 'Int', 'perl_int', 3 ],
    #         'y' => [ 'Int', 'perl_int', 2 ],
    #         'z' => [ 'Int', 'perl_int', 4 ],
    #     },
    # ] ]

For most examples of using Muldis Rosetta, and tutorials, please see the
separate L<Muldis::Rosetta::Cookbook> distribution (when that comes to
exist).

=head1 DESCRIPTION

B<Muldis::Rosetta::Interface>, aka I<Interface>, comprises the minimal core
of the Muldis Rosetta framework, the one component that probably every
program would use.  Together with the Muldis D language (see L<Muldis::D>),
it defines the common API for Muldis Rosetta implementations to do and
which applications invoke.

I<This documentation is pending.>

=head1 INTERFACE

The interface of Muldis::Rosetta::Interface is fundamentally
object-oriented; you use it by creating objects from its member classes (or
more specifically, of implementing classes that compose its member roles)
and then invoking methods on those objects.  All of their attributes are
private, so you must use accessor methods.

To aid portability of your applications over multiple implementing Engines,
the normal way to create Interface objects is by invoking a
constructor-wrapping method of some other object that would provide context
for it; since you generally don't have to directly invoke any package
names, you don't need to change your code when the package names change due
to switching the Engine.  You only refer to some Engine's root package name
once, as a C<Muldis::Rosetta::Interface::new_machine> argument, and even
that can be read from a config file rather than being hard-coded in your
application.

The usual way that Muldis::Rosetta::Interface indicates a failure is to
throw an exception; most often this is due to invalid input.  If an invoked
routine simply returns, you can assume that it has succeeded, even if the
return value is undefined.

=head2 The Muldis::Rosetta::Interface Module

The C<Muldis::Rosetta::Interface> module is the stateless root package by
way of which you access the whole Muldis Rosetta API.  That is, you use it
to load engines and instantiate virtual machines, which provide the rest of
the Muldis Rosetta API.

=over

=item C<new_machine of Muldis::Rosetta::Interface::Machine (Str
:$engine_name!, Any :$machine_config?)>

This constructor function creates and returns a C<Machine> object that is
implemented by the Muldis Rosetta Engine named by its named argument
C<$engine_name>; that object is initialized using the C<$machine_config>
argument.  The named argument C<$engine_name> is the name of a Perl module
that is expected to be the root package of a Muldis Rosetta Engine, and
which is expected to declare a C<new_machine> subroutine with a single
named argument C<$machine_config>; invoking this subroutine is expected to
return an object of some class of the same Engine which does the
C<Muldis::Rosetta::Interface::Machine> role.  This function will start by
testing if the root package is already loaded (it may be declared by some
already-loaded file of another name), and only if not, will it do a Perl
'require' of the C<$engine_name>.

=back

=head2 The Muldis::Rosetta::Interface::Machine Role

A C<Machine> object represents a single active Muldis Rosetta virtual
machine / Muldis D environment, which is the widest scope stateful context
in which any other database activities happen.  Other activities meaning
the compilation and execution of Muldis D code, mounting or unmounting
depots, performing queries, data manipulation, data definition, and
transactions.  If a C<Machine> object is ever garbage collected by Perl
while it has any active transactions, then those will all be rolled back,
and then an exception thrown.

=over

=item C<new_process of Muldis::Rosetta::Interface::Process (Any
:$process_config?)>

This method creates and returns a new C<Process> object that is associated
with the invocant C<Machine>; that C<Process> object is initialized using
the C<$process_config> argument.

=back

=head2 The Muldis::Rosetta::Interface::Process Role

A C<Process> object represents a single Muldis Rosetta in-DBMS process,
which has its own autonomous transactional context, and for the most part,
its own isolated environment.  It is associated with a specific C<Machine>
object, the one whose C<new_process> method created it.

A new C<Process> object's "expected plain-text|Perl-hosted-data command
language" attribute is undefined by default, meaning that each
plain-text|Perl-hosted-data command fed to the process must declare what
plain-text|Perl-hosted-data language it is written in, and according to
that declaration will the command be interpreted; if that attribute was
made defined, then plain-text|Perl-hosted-data commands fed to the process
either must not declare their plain-text|Perl-hosted-data language or must
declare the same plain-text|Perl-hosted-data language as the attribute, and
so the command will be interpreted according to the expected
plain-text|Perl-hosted-data language attribute.

=over

=item C<assoc_machine of Muldis::Rosetta::Interface::Machine ()>

This method returns the C<Machine> object that the invocant C<Process> is
associated with.

=item C<pt_command_lang of Str ()>

This method returns the fully qualified name of its invocant C<Process>
object's "expected plain-text command language" attribute, which might be
undefined; if it is defined, then is a Perl Str that names a Plain Text
language; these may be Muldis D dialects or some other language.

=item C<update_pt_command_lang (Str :$lang!)>

This method assigns a new (possibly undefined) value to its invocant
C<Process> object's "expected plain-text command language" attribute.  This
method dies if the specified language is defined and its value isn't one
that the invocant's Engine knows how to or desires to handle.

=item C<hd_command_lang of Array ()>

This method returns the fully qualified name of its invocant C<Process>
object's "expected Perl-hosted-data command language" attribute, which
might be undefined; if it is defined, then is a Perl (ordered) Array that
names a Perl Hosted Data language; these may be Muldis D dialects or some
other language.

=item C<update_hd_command_lang (Array :$lang!)>

This method assigns a new (possibly undefined) value to its invocant
C<Process> object's "expected Perl-hosted-data command language" attribute.
This method dies if the specified language is defined and its value isn't
one that the invocant's Engine knows how to or desires to handle.

=item C<execute (Any :$source_code!)>

This method compiles and executes the (typically Muldis D) source code
given in its C<$source_code> argument.  If C<$source_code> is a Perl Str
then it is treated as being written in a plain-text language; if
C<$source_code> is any kind of Perl 5 reference or Perl 5 object then it is
treated as being written in a Perl-hosted-data language.  This method dies
if the source code fails to compile for some reason, or if the executing
code has a runtime exception.

=item C<new_value of Muldis::Rosetta::Interface::Value (Any
:$source_code!)>

This method creates and returns a new C<Value> object that is associated
with the invocant C<Process>; that C<Value> object is initialized using the
(typically Muldis D) source code given in its C<$source_code> argument,
which defines a value literal.  If C<$source_code> is a Perl Str then it is
treated as being written in a plain-text language; if C<$source_code> is
any kind of Perl 5 reference or Perl 5 object then it is treated as being
written in a Perl-hosted-data language.  If C<$source_code> is written in
Perl Hosted Muldis D, it would typically be a Perl (ordered) Array; but if
one wants to declare a C<Value> in that language that is just a Muldis D
C<Cat.Name>, then C<$source_code> must be a Perl 5 scalar reference to a
Perl Str rather than just being a Perl Str as the Perl Hosted Muldis D spec
states, in order to disambiguate this kind of Perl-hosted-data code from
plain-text code.  If the C<$source_code> is in a Perl Hosted Data language,
then it may consist partially of other C<Value> objects.  If
C<$source_code> is itself just a C<Value> object, then it will be cloned.

=item C<func_invo of Muldis::Rosetta::Interface::Value (Str :$function!,
Hash :$args?)>

This method invokes the Muldis D function named by its C<$function>
argument, giving it arguments from C<$args>, and then returning the result
as a C<Value> object.  Each C<$args> Hash key must match the name of a
parameter of the named function, and the corresponding Hash value is the
argument for that parameter; each Hash value may be either a C<Value>
object or some other Perl value that would be suitable as the sole
constructor argument for a new C<Value> object.

=item C<upd_invo (Str :$updater!, Hash :$upd_args!, Hash :$ro_args?)>

This method invokes the Muldis D updater named by its C<$updater> argument,
giving it subject-to-update arguments from C<$upd_args> and read-only
arguments from C<$ro_args>; the C<Value> objects in C<$upd_args> are
possibly substituted for other C<Value> objects as a side-effect of the
updater's execution.  The C<$ro_args> parameter is as per the C<$args>
parameter of the C<func_invo> method, but the C<$upd_args> parameter is a
bit different; each Hash value in the C<$upd_args> argument must be a Perl
scalar reference pointing to the Perl variable being bound to the
subject-to-update parameter; said Perl variable is then what holds a
C<Value> object et al prior to the updater's execution, and that may have
been updated to hold a different C<Value> object as a side-effect.

=item C<proc_invo (Str :$procedure!, Hash :$upd_args?, Hash :$ro_args?)>

This method invokes the Muldis D procedure (or system_service) named by its
C<$procedure> argument, giving it subject-to-update arguments from
C<$upd_args> and read-only arguments from C<$ro_args>; the C<Value> objects
in C<$upd_args> are possibly substituted for other C<Value> objects as a
side-effect of the procedure's execution.  The parameters of C<proc_invo>
are as per those of the C<upd_invo> method, save that only C<upd_invo>
makes C<$upd_args> mandatory, while C<proc_invo> makes it optional.

=item C<trans_nest_level of Int ()>

This method returns the current transaction nesting level of its invocant's
virtual machine process.  If no explicit transactions were started, then
the nesting level is zero, in which case the process is conceptually
auto-committing every successful Muldis D statement.  Each call of
C<start_trans> will increase the nesting level by one, and each
C<commit_trans> or C<rollback_trans> will decrease it by one (it can't be
decreased below zero).  Note that all transactions started or ended within
Muldis D code (except direct boot_call transaction management) are attached
to a particular lexical scope in the Muldis D code (specifically a
"try/catch" context), and so they will never have any effect on the nest
level that Perl sees (assuming that a Muldis D host language will never be
invoked by Muldis D), regardless of whether the Muldis D code successfully
returns or throws an exception.

=item C<start_trans ()>

This method starts a new child-most transaction within the invocant's
virtual machine process.

=item C<commit_trans ()>

This method commits the child-most transaction within the invocant's
virtual machine process; it dies if there isn't one.

=item C<rollback_trans ()>

This method rolls back the child-most transaction within the invocant's
virtual machine process; it dies if there isn't one.

=back

=head2 The Muldis::Rosetta::Interface::Value Role

A C<Value> object represents a single Muldis Rosetta in-DBMS value, which
is conceptually immutable, eternal, and not fixed in time or space; the
object is immutable.  It is associated with a specific C<Process> object,
the one whose C<new_value> method created it.  You can use C<Value> objects
in Perl routines the same as normal immutable Perl values or objects,
including that you just do ordinary Perl variable assignment.  C<Value>
objects are the normal way to directly share or move data between the
Muldis Rosetta DBMS and main Perl environments.  The value that a C<Value>
object represents is set when the C<Value> object is created, and it can't
be changed afterwards.

=over

=item C<assoc_process of Muldis::Rosetta::Interface::Process ()>

This method returns the C<Process> object that the invocant C<Value> is
associated with.

=item C<pt_source_code of Str (Str :$lang?)>

This method returns (typically Muldis D) plain-text source code that
defines a value literal equivalent to the in-DBMS value that the invocant
C<Value> represents.  The plain-text language of the source code to return
must be explicitly specified, typically by ensuring that the C<Process>
object associated with this C<Value> has a defined "expected plain-text
command language" attribute; alternately a defined C<$lang> argument may be
used, but if that argument is given while the attribute is defined, then
the 2 values must match.

=item C<hd_source_code of Any (Array :$lang?)>

This method returns (typically Muldis D) Perl-hosted-data source code that
defines a value literal equivalent to the in-DBMS value that the invocant
C<Value> represents.  The Perl-hosted-data language of the source code to
return must be explicitly specified, typically by ensuring that the
C<Process> object associated with this C<Value> has a defined "expected
Perl-hosted-data command language" attribute; alternately a defined
C<$lang> argument may be used, but if that argument is given while the
attribute is defined, then the 2 values must match.

=back

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

It also requires these Perl 5 packages that are on CPAN:
L<Moose::Role-0.55|Moose::Role>.

=head1 INCOMPATIBILITIES

None reported.

=head1 SEE ALSO

Go to L<Muldis::Rosetta> for the majority of distribution-internal
references, and L<Muldis::Rosetta::SeeAlso> for the majority of
distribution-external references.

=head1 BUGS AND LIMITATIONS

The Muldis Rosetta framework for Perl 5 is built according to certain
old-school or traditional Perl-5-land design principles, including that
there are no explicit attempts in code to enforce privacy of the
framework's internals, besides not documenting them as part of the public
API.  (The Muldis Rosetta framework for Perl 6 is different.)  That said,
you should still respect that privacy and just use the public API that
Muldis Rosetta provides.  If you bypass the public API anyway, as Perl 5
allows, you do so at your own peril.

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
