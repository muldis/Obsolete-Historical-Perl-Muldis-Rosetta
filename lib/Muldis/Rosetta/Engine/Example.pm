use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

use Muldis::Rosetta::Interface 0.011001;
use Muldis::Rosetta::Util::Tiny 0.000000;

use Muldis::Rosetta::Engine::Example::Value 0.000000;
use Muldis::Rosetta::Engine::Example::Routines 0.000000;
use Muldis::Rosetta::Engine::Example::Storage 0.000000;
use Muldis::Rosetta::Engine::Example::Runtime 0.000000;
use Muldis::Rosetta::Engine::Example::Util 0.000000;

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Engine::Example; # module
    use version 0.74; our $VERSION = qv('0.11.1');
    # Note: This given version applies to all of this file's packages.

###########################################################################

sub new_machine {
    return Muldis::Rosetta::Engine::Example::Public::Machine->new();
}

###########################################################################

} # module Muldis::Rosetta::Engine::Example

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Engine::Example::Public::Machine; # class
    use MooseX::Singleton 0.11;

    with 'Muldis::Rosetta::Interface::Machine';

    has '_inner' => (
        is      => 'rw',
        isa     => 'Muldis::Rosetta::Engine::Example::Runtime::Machine',
        default => sub {
            Muldis::Rosetta::Engine::Example::Runtime::Machine->new()
        },
    );

###########################################################################

sub new_process {
    my ($self, $args) = @_;
    my ($process_config) = @{$args}{'process_config'};
    return Muldis::Rosetta::Engine::Example::Public::Process->new({
        'assoc_machine' => $self, 'process_config' => $process_config });
}

###########################################################################

    __PACKAGE__->meta()->make_immutable();
} # class Muldis::Rosetta::Engine::Example::Public::Machine

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Engine::Example::Public::Process; # class
    use Moose 0.57;

    with 'Muldis::Rosetta::Interface::Process';

    has '_assoc_machine' => (
        is       => 'ro',
        isa      => 'Muldis::Rosetta::Engine::Example::Public::Machine',
        init_arg => 'assoc_machine',
        required => 1,
    );

    has '_inner' => (
        is      => 'rw',
        isa     => 'Muldis::Rosetta::Engine::Example::Runtime::Process',
# Disabled since Moose::Role's "requires" doesn't recog auto-gen methods.
#        handles => [qw(
#            trans_nest_level start_trans commit_trans rollback_trans
#        )],
    );

    has '_pt_command_lang' => (
        is  => 'rw',
        isa => 'Maybe[Str]',
    );
    has '_hd_command_lang' => (
        is  => 'rw',
        isa => 'Maybe[ArrayRef]',
    );

###########################################################################

sub BUILD {
    my ($self, $args) = @_;
    my ($process_config) = @{$args}{'process_config'};

    defined $process_config or $process_config = {};
    confess q{new_process(): Bad :$process_config arg; Perl 5 does not}
            . q{ consider it to be a Hash.}
        if ref $process_config ne 'HASH';
    # TODO: further input checks on $process_config as applicable.

    $self->_inner( Muldis::Rosetta::Engine::Example::Runtime::Process
            ->new({
        'assoc_machine'  => $self->_assoc_machine()->_inner(),
        'process_config' => $process_config
    }) );

    return;
}

###########################################################################

# Needed since Moose::Role's "requires" doesn't recognize auto-gen methods.

sub assoc_machine {
    my ($self) = @_;
    return $self->_assoc_machine();
}

###########################################################################

sub pt_command_lang {
    my ($self) = @_;
    return $self->_pt_command_lang();
}

sub update_pt_command_lang {
    my ($self, $args) = @_;
    my ($lang) = @{$args}{'lang'};
    # TODO: validate $lang.
    $self->_pt_command_lang( $lang );
    return;
}

sub hd_command_lang {
    my ($self) = @_;
    return $self->_hd_command_lang();
}

sub update_hd_command_lang {
    my ($self, $args) = @_;
    my ($lang) = @{$args}{'lang'};
    # TODO: validate $lang.
    $self->_hd_command_lang( $lang );
    return;
}

###########################################################################

sub execute {
    my ($self, $args) = @_;
    my ($source_code, $lang) = @{$args}{'source_code', 'lang'};

    confess q{execute(): Bad :$source_code arg; it is undefined.}
        if !defined $source_code;

    # TODO: validate $lang.

    my $boot_call_seq; # Perl array of what each boot_call parses into

    if (ref $source_code) {
        $boot_call_seq = Muldis::Rosetta::Engine::Example::HostedData
                ->boot_call_seq_from_source_code({
            'assoc_process' => $self->_inner(),
            'source_code' => $source_code,
            'exp_command_lang' => $self->_hd_command_lang(),
        });
    }

    else {
        $boot_call_seq = Muldis::Rosetta::Engine::Example::PlainText
                ->boot_call_seq_from_source_code({
            'assoc_process' => $self->_inner(),
            'source_code' => $source_code,
            'exp_command_lang' => $self->_pt_command_lang(),
        });
    }

    # TODO: execute $boot_call_seq

    return;
}

###########################################################################

sub new_value {
    my ($self, $args) = @_;
    my ($source_code, $lang) = @{$args}{'source_code', 'lang'};
    return Muldis::Rosetta::Engine::Example::Public::Value->new({
        'assoc_process' => $self, 'source_code' => $source_code,
        'lang' => $lang });
}

###########################################################################

sub func_invo {
    my ($self, $args) = @_;
    my ($function, $f_args, $pt_lang, $hd_lang)
        = @{$args}{'function', 'args', 'pt_lang', 'hd_lang'};

    my $result = $self->new_value({ 'source_code' => 1 }); # TODO real work

    return $result;
}

sub upd_invo {
    my ($self, $args) = @_;
    my ($updater, $upd_args, $ro_args, $pt_lang, $hd_lang)
        = @{$args}{'updater', 'upd_args', 'ro_args', 'pt_lang', 'hd_lang'};

    # TODO, the real work

    return;
}

sub proc_invo {
    my ($self, $args) = @_;
    my ($procedure, $upd_args, $ro_args, $pt_lang, $hd_lang) = @{$args}{
        'procedure', 'upd_args', 'ro_args', 'pt_lang', 'hd_lang'};

    # TODO, the real work

    return;
}

###########################################################################

# Needed since Moose::Role's "requires" doesn't recognize auto-gen methods.

sub trans_nest_level {
    my ($self) = @_;
    return $self->_inner()->trans_nest_level();
}

sub start_trans {
    my ($self) = @_;
    $self->_inner()->start_trans();
    return;
}

sub commit_trans {
    my ($self) = @_;
    $self->_inner()->commit_trans();
    return;
}

sub rollback_trans {
    my ($self) = @_;
    $self->_inner()->rollback_trans();
    return;
}

###########################################################################

    __PACKAGE__->meta()->make_immutable();
} # class Muldis::Rosetta::Engine::Example::Public::Process

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Engine::Example::Public::Value; # class
    use Moose 0.57;

    with 'Muldis::Rosetta::Interface::Value';

    has '_assoc_process' => (
        is       => 'ro',
        isa      => 'Muldis::Rosetta::Engine::Example::Public::Process',
        init_arg => 'assoc_process',
        required => 1,
    );

    has '_inner' => (
        is   => 'rw',
        does => 'Muldis::Rosetta::Engine::Example::Value::Universal',
    );

###########################################################################

sub BUILD {
    my ($self, $args) = @_;
    my ($source_code, $lang) = @{$args}{'source_code', 'lang'};

    confess q{new_value(): Bad :$source_code arg; it is undefined.}
        if !defined $source_code;

    # TODO: validate $lang.

    my $assoc_process = $self->_assoc_process();

    if (ref $source_code) {
#        $self->_inner( Muldis::Rosetta::Engine::Example::HostedData
#                ->value_from_source_code({
#            'assoc_process' => $assoc_process->_inner(),
#            'source_code' => $source_code,
#            'exp_command_lang' => $assoc_process->_hd_command_lang(),
#        }) );
    }

    else {
#        $self->_inner( Muldis::Rosetta::Engine::Example::PlainText
#                ->value_from_source_code({
#            'assoc_process' => $assoc_process->_inner(),
#            'source_code' => $source_code,
#            'exp_command_lang' => $assoc_process->_pt_command_lang(),
#        }) );
    }

    return;
}

###########################################################################

# Needed since Moose::Role's "requires" doesn't recognize auto-gen methods.

sub assoc_process {
    my ($self) = @_;
    return $self->_assoc_process();
}

###########################################################################

sub pt_source_code {
    my ($self, $args) = @_;
    my ($lang) = @{$args}{'lang'};
    # TODO: validate $lang.
#    return Muldis::Rosetta::Engine::Example::PlainText
#            ->source_code_from_value({
#        'value' => $self->_inner(),
#        'exp_command_lang'
#            => ($lang || $self->_assoc_process()->_pt_command_lang()),
#    });
    return;
}

sub hd_source_code {
    my ($self, $args) = @_;
    my ($lang) = @{$args}{'lang'};
    # TODO: validate $lang.
#    return Muldis::Rosetta::Engine::Example::HostedData
#            ->source_code_from_value({
#        'value' => $self->_inner(),
#        'exp_command_lang'
#            => ($lang || $self->_assoc_process()->_hd_command_lang()),
#    });
    return;
}

###########################################################################

    __PACKAGE__->meta()->make_immutable();
} # class Muldis::Rosetta::Engine::Example::Public::Value

###########################################################################
###########################################################################

1; # Magic true value required at end of a reusable file's code.
__END__

=pod

=encoding utf8

=head1 NAME

Muldis::Rosetta::Engine::Example -
Self-contained reference implementation of a Muldis Rosetta Engine

=head1 VERSION

This document describes Muldis::Rosetta::Engine::Example version 0.11.1 for
Perl 5.

It also describes the same-number versions for Perl 5 of
Muldis::Rosetta::Engine::Example::Public::Machine,
Muldis::Rosetta::Engine::Example::Public::Process,
Muldis::Rosetta::Engine::Example::Public::Value.

=head1 SYNOPSIS

I<This documentation is pending.>

=head1 DESCRIPTION

B<Muldis::Rosetta::Engine::Example>, aka the I<Muldis Rosetta Example
Engine>, aka I<Example>, is the self-contained and pure-Perl reference
implementation of Muldis Rosetta.  It is included in the Muldis Rosetta
core distribution to allow the core to be completely testable on its own.

Example is coded intentionally in a simple fashion so that it is easy to
maintain and and easy for developers to study.  As a result, while it
performs correctly and reliably, it also performs quite slowly; you should
only use Example for testing, development, and study; you should not use it
in production.  (See the L<Muldis::Rosetta::SeeAlso> file for a list of
other Engines that are more suitable for production.)

This C<Muldis::Rosetta::Engine::Example> file is the main file of the
Example Engine, and it is what applications quasi-directly invoke; its
C<Muldis::Rosetta::Engine::Example::Public::\w+> classes directly
do/compose the roles in L<Muldis::Rosetta::Interface>.  The other
C<Muldis::Rosetta::Engine::Example::\w+> files are used internally by this
file, comprising the rest of the Example Engine, and are not intended to be
used directly in user code.

=head2 Implementation and Limitations

Example, loosely speaking, uses the SQLite DBMS as a model for
implementation.  Example uses a single file on disk to represent an entire
persisting depot, including all of its schemata and data, and users may
store this file anywhere they want and with any name they want (subject to
filesystem limitations); Example does not store a collection of multiple
files in a fixed location like most large DBMSs.  Example will create a
temporary rollback journal file for a depot when it is about to write
changes to the depot file, though unlike SQLite this journal is actually
just a copy of the entire file, not just the portions that are being
changed.

There are some intentional design decisions of Example that significantly
impact performance or scalability but don't impact behaviour, which are
listed next; it is not expected these will be changed, due to Example's
intended use for testing and learning, to keep it simple, though they might
end up being changed anyway if the simplicity goal of Example isn't
compromosed in the process:

=over

=item Database lives in RAM

Example is fundamentally a RAM-based DBMS; any I<temporary> (RAM-based)
depot represents Example's native way of doing things most faithfully, as
it is just a tree of ordinary Perl objects.  Any persisting
(disk-file-based) depot is loaded entirely into RAM when mounted and
deserialized into such a tree of Perl objects, where it then lives like a
temporary depot; when a parent-most transaction commits with changes to the
loaded depot, then the entire depot is serialized and the entire disk file
is rewritten over (but a typical rollback has essentially no cost).  So the
maximum size of any Example depot is limited to what can entirely fit in
RAM when not serialized.  It also stands to reason in general that
aggregating many updates into a single parent-most transaction will perform
better than committing each one separately, since then only one rewrite to
disk would occur.

=item Locks are on whole files

Access to the same disk-file-based depot by multiple Perl processes will be
mediated by whole-file locks; multiple Perl processes may have readonly
access to the same file at once, but only one Perl process may have write
access at once, when it is the only process with a lock on the file;
different Perl processes can not get locks on different parts of the same
file at once in order to do non-conflicting updates.  That said, some tasks
can be made more efficient by utilizing multiple in-DBMS processes within a
single Perl process, rather than single in-DBMS processes within multiple
Perl processes.  One reason is that all in-DBMS processes of a common Perl
process will cooperate on actual access to a single file, and can make
non-conflicting updates at once; moreover, a depot is only loaded into RAM
once to be shared by all inner processes.  In other words, wrapping up an
Example Machine object in a DBMS server Perl process with multiple clients
may improve concurrency for some tasks.

=item Immutable value objects

Every in-DBMS value, whether simple or complex, is represented by a mostly
immutable object tree.  No value objects are updated in place; any
operation that would derive a new value from an old one will create a new
value object and the old one will be left alone; this is even true for
collection values like tuples or relations; this means copy-on-write by
default.  The resulting semantics are that to some extent the DBMS is
multi-versioned; anyone referencing an object can conceptually update it
while others that hold it continue to have a consistent view; we get safety
simply.  Its also easier to support nested transactions and rollbacks; a
rollback just means discarding a newly derived value and using the previous
one.  While some explicit concurrency management is necessary, such as when
one makes a change to a depot they want to commit, a lot of work is saved.
The main trade-off here is that updates of large collections like a relvar
might be slower though possibly not.

=item Brute force by default

Example will default to doing most operations with brute force by default
if that is the simplest way to code them up; but some indexes/etc will be
used where a lot of gain can be had for little coding effort.

=back

=head1 INTERFACE

Muldis::Rosetta::Engine::Example supports multiple command languages, all
of which are official Muldis D dialects.  You may supply commands to
Example written in any of the following:

=over

=item B<Tiny Plain Text Muldis D>

See L<Muldis::D::Dialect::PTMD_Tiny> for details.

The language name is specified either as a Perl character string whose
value is C<Muldis_D:'http://muldis.com':'0.47.0':'PTMD_Tiny':{}> or as a
Perl array whose value is C<[ 'Muldis_D', 'http://muldis.com', '0.47.0',
'PTMD_Tiny', {} ]>.  No other version numbers are currently supported.

=item B<Tiny Perl Hosted Data Muldis D>

See L<Muldis::D::Dialect::HDMD_Perl_Tiny> for details.

The language name is specified either as a Perl character string whose
value is C<Muldis_D:'http://muldis.com':'0.47.0':'HDMD_Perl_Tiny':{}> or as
a Perl array whose value is C<[ 'Muldis_D', 'http://muldis.com', '0.47.0',
'HDMD_Perl_Tiny', {} ]>.  No other version numbers are currently supported.

=back

You may also supply or retrieve data through Example in any of the above.

=head1 DIAGNOSTICS

I<This documentation is pending.>

=head1 CONFIGURATION AND ENVIRONMENT

I<This documentation is pending.>

=head1 DEPENDENCIES

The Muldis Rosetta Example Engine, meaning the collection of files that
includes this file and all other C<Muldis::Rosetta::Engine::Example::\w+>
files, requires any version of Perl 5.x.y that is at least 5.8.1, and
recommends one that is at least 5.10.0.

It also requires these Perl 5 packages that are bundled with any version of
Perl 5.x.y that is at least 5.10.0, and are also on CPAN for separate
installation by users of earlier Perl versions: L<version-0.74|version>.

It also requires these Perl 5 packages that are on CPAN:
L<Moose-0.57|Moose>, L<Moose::Role-0.57|Moose::Role>,
L<MooseX::Singleton-0.11|MooseX::Singleton>.

It also requires these Perl 5 classes that are in the current distribution:
L<Muldis::Rosetta::Interface-0.11.1|Muldis::Rosetta::Interface>.

=head1 INCOMPATIBILITIES

None reported.

=head1 SEE ALSO

Go to L<Muldis::Rosetta> for the majority of distribution-internal
references, and L<Muldis::Rosetta::SeeAlso> for the majority of
distribution-external references.

=head1 BUGS AND LIMITATIONS

Although Muldis::Rosetta::Engine::Example is supposed to implement the
features and semantics of the entire Muldis D language, it has several
limitations which are not expected to be surmounted in the short term, due
to intentional design decisions for speeding development; but they I<are>
expected to be addressed in the longer term:

=over

=item No multi-file atomic commits

Each in-DBMS process may have no more than one depot mount at any given
time whose C<is_temporary> flag is false and whose C<we_may_update> flag is
true; in other words, atomic commits against multiple persistent
(disk-file-based) depots are not yet supported.  However, in addition to
one such depot mount, any number of updateable temporary (RAM-based) depot
mounts or read-only persistent (disk-file-based) depot mounts may exist in
a single in-DBMS process at once.  So the most common DBMS usage scenarios
should still be supported.

=back

If any existing Example feature/behaviour limitations are not listed in
this file, then they are expected to be addressed in the short term.

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
