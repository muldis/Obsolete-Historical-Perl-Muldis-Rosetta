use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Util::Tiny; # module
    use version 0.74; our $VERSION = qv('0.0.0');
    # Note: This given version applies to all of this file's packages.

    use Carp;
    use Scalar::Util 'blessed', 'openhandle';

###########################################################################

sub new_token_stream {
    my ($args) = @_;
    my ($source_code) = @{$args}{'source_code'};

    # Note that $source_code might be any of:
    # 1. A language declaration (the value of an Engine's $lang argument).
    # 2. A bootloader fragment (with or without leading language decl).
    # 3. A value literal (possibly just a ::Value object).

    confess q{new_token_stream(): Bad :$source_code arg; it is undefined.}
        if !defined $source_code;

    my $ref_kind = ref $source_code;

    if (!$ref_kind) { # TODO: or test if obj that represents a Str
        return Muldis::Rosetta::Util::Tiny::TokenStream::FromPTStr->new({
            '_source' => $source_code });
    }

    elsif ($ref_kind eq 'ARRAY' or $ref_kind eq 'SCALAR'
            or blessed $source_code and $source_code->isa(
            'Moose::Object' ) and $source_code->does(
            'Muldis::Rosetta::Interface::Value' )) {
        return Muldis::Rosetta::Util::Tiny::TokenStream::FromHDArray->new({
            '_source' => $source_code });
    }

    elsif ($ref_kind eq 'GLOB' and openhandle $source_code
            or blessed $source_code and $source_code->isa( 'IO::Handle' )
            ) { # TODO: or test if obj that repr a FileHandle another way
        return Muldis::Rosetta::Util::Tiny::TokenStream::FromPTFH->new({
            '_source' => $source_code });
    }

    else { # $ref_kind eq 'HASH'|'CODE'|'Regexp'|other-'GLOB'|other-object
        confess q{new_token_stream(): Bad :$source_code arg; a}
            . qq{ '$ref_kind' is not discernable as the root of a source}
            . q{ of any Tiny dialect of Muldis D.};
    }
}

###########################################################################

sub language_from_source_code {
    my ($args) = @_;
    my ($source_code) = @{$args}{'source_code'};
    return __PACKAGE__::new_token_stream({ 'source_code' => $source_code })
        ->pull_language();
}

sub boot_call_from_source_code {
    my ($args) = @_;
    my ($source_code) = @{$args}{'source_code'};
    return __PACKAGE__::new_token_stream({ 'source_code' => $source_code })
        ->pull_boot_call();
}

sub value_from_source_code {
    my ($args) = @_;
    my ($source_code) = @{$args}{'source_code'};
    return __PACKAGE__::new_token_stream({ 'source_code' => $source_code })
        ->pull_value();
}

###########################################################################

} # module Muldis::Rosetta::Util::Tiny

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Util::Tiny::TokenStream; # role
#    use Moose::Role 0.58;
    use Moose::Role 0.57;

    has '_source' => (
        is       => 'ro', # but some kinds may still mutate when read from
        isa      => 'Defined',
        required => 1,
    );

    # These return undef if the next significant (non-whitespace/etc)
    # thing in the stream isn't what is asked for (stream doesn't advance).
    requires 'pull_language';  # expect start with 'Muldis_D'
    requires 'pull_boot_call'; # expect start with 'boot_call'
    requires 'pull_value';     # expect start with anything else

###########################################################################

###########################################################################

} # role Muldis::Rosetta::Util::Tiny::TokenStream

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Util::Tiny::TokenStream::FromPTStr; # class
    use Moose 0.58;

    with 'Muldis::Rosetta::Util::Tiny::TokenStream';

###########################################################################

sub pull_language {
    my ($self) = @_;
    return undef; # nothing found
}

sub pull_boot_call {
    my ($self) = @_;
    return undef; # nothing found
}

sub pull_value {
    my ($self) = @_;
    return undef; # nothing found
}

###########################################################################

    __PACKAGE__->meta()->make_immutable();
} # class Muldis::Rosetta::Util::Tiny::TokenStream::FromPTStr

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Util::Tiny::TokenStream::FromPTFH; # class
    use Moose 0.58;

    with 'Muldis::Rosetta::Util::Tiny::TokenStream';

    use autodie 1.994;

###########################################################################

sub pull_language {
    my ($self) = @_;
    return undef; # nothing found
}

sub pull_boot_call {
    my ($self) = @_;
    return undef; # nothing found
}

sub pull_value {
    my ($self) = @_;
    return undef; # nothing found
}

###########################################################################

    __PACKAGE__->meta()->make_immutable();
} # class Muldis::Rosetta::Util::Tiny::TokenStream::FromPTFH

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Util::Tiny::TokenStream::FromHDArray; # class
    use Moose 0.58;

    with 'Muldis::Rosetta::Util::Tiny::TokenStream';

###########################################################################

sub pull_language {
    my ($self) = @_;
    return undef; # nothing found
}

sub pull_boot_call {
    my ($self) = @_;
    return undef; # nothing found
}

sub pull_value {
    my ($self) = @_;
    return undef; # nothing found
}

###########################################################################

    __PACKAGE__->meta()->make_immutable();
} # class Muldis::Rosetta::Util::Tiny::TokenStream::FromHDArray

###########################################################################
###########################################################################

1; # Magic true value required at end of a reusable file's code.
__END__

=pod

=encoding utf8

=head1 NAME

Muldis::Rosetta::Util::Tiny -
Translate Muldis D source code between the 2 official Tiny dialects

=head1 VERSION

This document describes Muldis::Rosetta::Util::Tiny version 0.0.0 for Perl
5.

It also describes the same-number versions for Perl 5 of [...].

=head1 SYNOPSIS

I<This documentation is pending.>

=head1 DESCRIPTION

The Muldis::Rosetta::Util::Tiny Perl 5 module provides routines that take
C<PTMD_Tiny> dialect Muldis D source code and tokenize it into a concrete
syntax tree that is C<HDMD_Perl_Tiny> dialect Muldis D source code; the
module also provides routines that generate C<PTMD_Tiny> source code from
C<HDMD_Perl_Tiny> source code.  The 2 Tiny dialects are expressly designed
to correspond 1:1 in this way so that lossless conversions in both
directions can be done in complete isolation from an external context.

This module also provides routines for well-formedness validation of
existing C<HDMD_Perl_Tiny> source code.

More generally speaking, this module provides Muldis D Tiny dialect source
code format normalization, such that the same tokenizer routines will take
existing source code input in either of the C<PTMD_Tiny> or
C<PHMD_Perl_Tiny> dialects, and consistently return well-formed
C<PHMD_Perl_Tiny> source code; also, the C<PTMD_Tiny> code can be supplied
either as a Perl Str or as a Perl filehandle that is open for reading.

The Muldis::Rosetta::Util::Tiny module is available to be used by all
Muldis Rosetta Engines, and is at least used by
L<Muldis::Rosetta::Engine::Example>, to assist in parsing user-provided
Muldis D code by taking raw input in several possible dialects and
normalizing it into a quasi-internal single dialect concrete syntax tree,
which is easier for the rest of the Engine's parser to deal with.  It is
also available/used to assist in generating Muldis D source code in
multiple dialects from the quasi-internal concrete syntax tree.

This module does do some kinds of source code validation in the process of
normalizing it, mainly to do with well-formedness, but other kinds of
validation tests must still be performed on the result by the rest of the
Engine's parser/compiler/runtime, rather than treating the result as
"safe" in all ways.

TODO: remove following paragraph; this module will ensure no shared refs by
default, but users can pass control args where appropriate to specify
allowing sharing to assist performance.  END TODO.
Note that the result of one of this module's routines may be or contain
Perl references shared with all or part of the arguments of those routines,
particularly if normalizing an input that is already in a valid
C<PHMD_Perl_Tiny> dialect.  This is done for performance reasons under the
assumption that the invoker of those routines would be just using the
results transiently as a step to a further conversion that involves
copying, or that they would otherwise be making copies as necessary to be
safe.  I<This policy is subject to be revised, such as by allowing users to
specify that they always want a copy / lack of shared references with
inputs.>

=head1 INTERFACE

I<This documentation is pending.>

=head1 DIAGNOSTICS

I<This documentation is pending.>

=head1 CONFIGURATION AND ENVIRONMENT

I<This documentation is pending.>

=head1 DEPENDENCIES

This file requires any version of Perl 5.x.y that is at least 5.8.1, and
recommends one that is at least 5.10.0.

It also requires these Perl 5 packages that are bundled with any version of
Perl 5.x.y that is at least 5.10.0, and are also on CPAN for separate
installation by users of earlier Perl versions: L<version-0.74|version>.

It also requires these Perl 5 packages that are bundled with any version of
Perl 5.8.x that is at least 5.8.9 and any version of Perl 5.10.x that is at
least 5.10.1, and are also on CPAN for separate installation by users of
earlier Perl versions: L<autodie-1.994|autodie>.

It also requires these Perl 5 packages that are on CPAN:
L<Moose-0.58|Moose>, L<Moose::Role-0.58|Moose::Role>.

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
