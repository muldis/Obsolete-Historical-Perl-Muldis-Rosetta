use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

###########################################################################
###########################################################################

{ package Muldis::Rosetta::Engine::Example::HostedData; # package
    use version 0.74; our $VERSION = qv('0.0.0');
    # Note: This given version applies to all of this file's packages.
} # package Muldis::Rosetta::Engine::Example::HostedData

###########################################################################
###########################################################################

1; # Magic true value required at end of a reusable file's code.
__END__

=pod

=encoding utf8

=head1 NAME

Muldis::Rosetta::Engine::Example::HostedData -
Parser and builder of Perl Hosted Data Muldis D source code

=head1 VERSION

This document describes Muldis::Rosetta::Engine::Example::HostedData
version 0.0.0 for Perl 5.

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
