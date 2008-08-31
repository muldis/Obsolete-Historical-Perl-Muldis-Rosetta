use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

use Muldis::Rosetta::Interface 0.011000;

#use Muldis::Rosetta::Engine::Example::Runtime;
#use Muldis::Rosetta::Engine::Example::Value;
#use Muldis::Rosetta::Engine::Example::PlainText;
#use Muldis::Rosetta::Engine::Example::HostedData;

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Engine::Example; # module
    use version 0.74; our $VERSION = qv('0.11.0');
    # Note: This given version applies to all of this file's packages.

###########################################################################

sub new_machine {
    my ($args) = @_;
    my ($machine_config) = @{$args}{'machine_config'};
    return Muldis::Rosetta::Engine::Example::Public::Machine->new({
        'machine_config' => $machine_config });
}

###########################################################################

} # module Muldis::Rosetta::Engine::Example

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Engine::Example::Public::Machine; # class
    use Moose;

    with 'Muldis::Rosetta::Interface::Machine';

    has '_inner' => (
        is      => 'rw',
        isa     => 'Muldis::Rosetta::Engine::Example::Runtime::Machine',
        default => undef,
    );

###########################################################################

sub BUILD {
    my ($self, $args) = @_;
    my ($machine_config) = @{$args}{'machine_config'};

    # TODO: input checks on $machine_config.
    defined $machine_config or $machine_config = {};

#    $self->_inner( Muldis::Rosetta::Engine::Example::Runtime::Machine
#        ->new({ 'machine_config' => $machine_config }) );

    return;
}

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
    use Moose;

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
        default => undef,
# Disabled since Moose::Role's "requires" doesn't recog auto-gen methods.
#        handles => [qw(
#            trans_nest_level start_trans commit_trans rollback_trans
#        )],
    );

    has '_pt_command_lang' => (
        is      => 'rw',
        isa     => 'Maybe[Str]',
        default => undef,
    );
    has '_hd_command_lang' => (
        is      => 'rw',
        isa     => 'Maybe[ArrayRef]',
        default => undef,
    );

###########################################################################

sub BUILD {
    my ($self, $args) = @_;
    my ($process_config) = @{$args}{'process_config'};

    # TODO: input checks on $process_config.
    defined $process_config or $process_config = {};

#    $self->_inner( Muldis::Rosetta::Engine::Example::Runtime::Process
#            ->new({
#        'assoc_machine'  => $self->_assoc_machine->_inner,
#        'process_config' => $process_config
#    }) );

    return;
}

###########################################################################

# Needed since Moose::Role's "requires" doesn't recognize auto-gen methods.

sub assoc_machine {
    my ($self) = @_;
    return $self->_assoc_machine;
}

###########################################################################

sub pt_command_lang {
    my ($self) = @_;
    return $self->_pt_command_lang;
}

sub update_pt_command_lang {
    my ($self, $args) = @_;
    my ($lang) = @{$args}{'lang'};
    $self->_pt_command_lang( $lang );
    return;
}

sub hd_command_lang {
    my ($self) = @_;
    return $self->_hd_command_lang;
}

sub update_hd_command_lang {
    my ($self, $args) = @_;
    my ($lang) = @{$args}{'lang'};
    $self->_hd_command_lang( $lang );
    return;
}

###########################################################################

sub execute {
    my ($self, $args) = @_;
    my ($source_code) = @{$args}{'source_code'};

    # TODO: execute $source code

    return;
}

###########################################################################

sub new_value {
    my ($self, $args) = @_;
    my ($source_code) = @{$args}{'source_code'};
    return Muldis::Rosetta::Engine::Example::Public::Value->new({
        'assoc_process' => $self, 'source_code' => $source_code });
}

###########################################################################

sub func_invo {
    my ($self, $args) = @_;
    my ($function, $f_args) = @{$args}{'function', 'args'};

    my $result = $self->new_value({ 'source_code' => 1 }); # TODO real work

    return $result;
}

sub upd_invo {
    my ($self, $args) = @_;
    my ($updater, $upd_args, $ro_args)
        = @{$args}{'updater', 'upd_args', 'ro_args'};

    # TODO, the real work

    return;
}

sub proc_invo {
    my ($self, $args) = @_;
    my ($procedure, $upd_args, $ro_args)
        = @{$args}{'procedure', 'upd_args', 'ro_args'};

    # TODO, the real work

    return;
}

###########################################################################

# Needed since Moose::Role's "requires" doesn't recognize auto-gen methods.

sub trans_nest_level {
    my ($self) = @_;
    return $self->_inner->trans_nest_level;
}

sub start_trans {
    my ($self) = @_;
    $self->_inner->start_trans();
    return;
}

sub commit_trans {
    my ($self) = @_;
    $self->_inner->commit_trans();
    return;
}

sub rollback_trans {
    my ($self) = @_;
    $self->_inner->rollback_trans();
    return;
}

###########################################################################

    __PACKAGE__->meta()->make_immutable();
} # class Muldis::Rosetta::Engine::Example::Public::Process

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Engine::Example::Public::Value; # class
    use Moose;

    with 'Muldis::Rosetta::Interface::Value';

    has '_assoc_process' => (
        is       => 'ro',
        isa      => 'Muldis::Rosetta::Engine::Example::Public::Process',
        init_arg => 'assoc_process',
        required => 1,
    );

    has '_inner' => (
        is      => 'rw',
        does    => 'Muldis::Rosetta::Engine::Example::Value::Universal',
        default => undef,
    );

###########################################################################

sub BUILD {
    my ($self, $args) = @_;
    my ($source_code) = @{$args}{'source_code'};

    confess q{new_value(): Bad :$source_code arg; it is undefined.}
        if !defined $source_code;

    my $assoc_process = $self->_assoc_process;

    if (ref $source_code) {
#        $self->_inner( Muldis::Rosetta::Engine::Example::HostedData
#                ->value_from_source_code({
#            'assoc_process' => $assoc_process->_inner,
#            'source_code' => $source_code,
#            'exp_command_lang' => $assoc_process->_hd_command_lang,
#        }) );
    }

    else {
#        $self->_inner( Muldis::Rosetta::Engine::Example::PlainText
#                ->value_from_source_code({
#            'assoc_process' => $assoc_process->_inner,
#            'source_code' => $source_code,
#            'exp_command_lang' => $assoc_process->_pt_command_lang,
#        }) );
    }

    return;
}

###########################################################################

# Needed since Moose::Role's "requires" doesn't recognize auto-gen methods.

sub assoc_process {
    my ($self) = @_;
    return $self->_assoc_process;
}

###########################################################################

sub pt_source_code {
    my ($self, $args) = @_;
    my ($lang) = @{$args}{'lang'};
#    return Muldis::Rosetta::Engine::Example::PlainText
#            ->source_code_from_value({
#        'value' => $self->_inner,
#        'exp_command_lang'
#            => ($self->_assoc_process->_pt_command_lang || $lang),
#    });
    return;
}

sub hd_source_code {
    my ($self, $args) = @_;
    my ($lang) = @{$args}{'lang'};
#    return Muldis::Rosetta::Engine::Example::HostedData
#            ->source_code_from_value({
#        'value' => $self->_inner,
#        'exp_command_lang'
#            => ($self->_assoc_process->_hd_command_lang || $lang),
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

This document describes Muldis::Rosetta::Engine::Example version 0.11.0 for
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
do/subclass the roles/classes in L<Muldis::Rosetta::Interface>.  The other
C<Muldis::Rosetta::Engine::Example::\w+> files are used internally by this
file, comprising the rest of the Example Engine, and are not intended to be
used directly in user code.

I<This documentation is pending.>

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

This file requires any version of Perl 5.x.y that is at least 5.8.1, and
recommends one that is at least 5.10.0.

It also requires these Perl 5 packages that are bundled with any version of
Perl 5.x.y that is at least 5.10.0, and are also on CPAN for separate
installation by users of earlier Perl versions: L<version>.

It also requires these Perl 5 packages that are on CPAN:
L<Moose-0.55|Moose>.

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
