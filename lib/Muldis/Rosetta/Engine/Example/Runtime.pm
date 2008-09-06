use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Engine::Example::Runtime; # package
    use version 0.74; our $VERSION = qv('0.0.0');
    # Note: This given version applies to all of this file's packages.
} # package Muldis::Rosetta::Engine::Example::Runtime

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Engine::Example::Runtime::Machine; # class
    use MooseX::Singleton;

###########################################################################

sub BUILD {
    my ($self) = @_;

    # TODO: whatever needs it.

    return;
}

sub DEMOLISH {
    my ($self) = @_;
    # TODO: check for active trans and rollback.
    # Likewise with closing open files or whatever.
    return;
}

###########################################################################

    __PACKAGE__->meta()->make_immutable();
} # class Muldis::Rosetta::Engine::Example::Runtime::Machine

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Engine::Example::Runtime::Process; # class
    use Moose;

    has 'assoc_machine' => (
        is       => 'ro',
        isa      => 'Muldis::Rosetta::Engine::Example::Runtime::Machine',
        required => 1,
    );

    has 'trans_nest_level' => (
        is      => 'rw',
        isa     => 'Int',
        default => 0,
    );

###########################################################################

sub BUILD {
    my ($self) = @_;

    # TODO: whatever needs it.

    return;
}

sub DEMOLISH {
    my ($self) = @_;
    # TODO: check for active trans and rollback.
    # Likewise with closing open files or whatever.
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

sub func_invo {
    my ($self, $args) = @_;
    my ($function, $f_args) = @{$args}{'function', 'args'};

    my $result = $self->new_value(); # TODO, the real work

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

sub start_trans {
    my ($self) = @_;
    # TODO: the actual work.
    $self->trans_nest_level( $self->trans_nest_level() ++ );
    return;
}

sub commit_trans {
    my ($self) = @_;
    confess q{commit_trans(): Could not commit a transaction;}
            . q{ none are currently active.}
        if $self->trans_nest_level() == 0;
    # TODO: the actual work.
    $self->trans_nest_level( $self->trans_nest_level() -- );
    return;
}

sub rollback_trans {
    my ($self) = @_;
    confess q{rollback_trans(): Could not rollback a transaction;}
            . q{ none are currently active.}
        if $self->trans_nest_level() == 0;
    # TODO: the actual work.
    $self->trans_nest_level( $self->trans_nest_level() -- );
    return;
}

###########################################################################

    __PACKAGE__->meta()->make_immutable();
} # class Muldis::Rosetta::Engine::Example::Runtime::Process

###########################################################################
###########################################################################

1; # Magic true value required at end of a reusable file's code.
__END__

=pod

=encoding utf8

=head1 NAME

Muldis::Rosetta::Engine::Example::Runtime -
Main DBMS state manager and event loop

=head1 VERSION

This document describes Muldis::Rosetta::Engine::Example::Runtime version
0.0.0 for Perl 5.

It also describes the same-number versions for Perl 5 of [...].

=head1 DESCRIPTION

This file is used internally by L<Muldis::Rosetta::Engine::Example>; it is
not intended to be used directly in user code.

I<This documentation is pending.>

=head1 BUGS AND LIMITATIONS

This file assumes that it will only be invoked by other components of
Example, and that they will only be feeding it arguments that are exactly
what it requires.  In general this file will not be doing any basic
argument validation, for simplicity and performance reasons; any invoker
should be validating any arguments that it in turn got from user code; the
exception is in the specific circumstances where it is this file's job
within Example do validation.  Moreover, this file will often take or
return values by reference, also for performance, and the in-Example caller
is expected to know when they should not be modifying said then-shared
values afterwards.

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
