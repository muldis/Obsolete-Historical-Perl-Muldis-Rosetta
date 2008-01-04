use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

###########################################################################
###########################################################################

my $BOOL_FALSE = (1 == 0);
my $BOOL_TRUE  = (1 == 1);

my $ORDER_INCREASE = (1 <=> 2);
my $ORDER_SAME     = (1 <=> 1);
my $ORDER_DECREASE = (2 <=> 1);

my $EMPTY_STR = q{};

###########################################################################
###########################################################################

{ package Muldis::DB::Engine::Example::Value; # module
    use version; our $VERSION = qv('0.0.0');
    # Note: This given version applies to all of this file's packages.

    use base 'Exporter';
    our @EXPORT_OK = qw(
        newBool newOrder newInt newRat newBlob newText
        newQuasiTuple newTuple newQuasiRelation newRelation
    );

###########################################################################

sub newBool {
    my ($args) = @_;
    my ($v) = @{$args}{'v'};
    return Muldis::DB::Engine::Example::Value::Bool->new({ 'v' => $v });
}

sub newOrder {
    my ($args) = @_;
    my ($v) = @{$args}{'v'};
    return Muldis::DB::Engine::Example::Value::Order->new({ 'v' => $v });
}

sub newInt {
    my ($args) = @_;
    my ($v) = @{$args}{'v'};
    return Muldis::DB::Engine::Example::Value::Int->new({ 'v' => $v });
}

sub newRat {
    my ($args) = @_;
    my ($v) = @{$args}{'v'};
    return Muldis::DB::Engine::Example::Value::Rat->new({ 'v' => $v });
}

sub newBlob {
    my ($args) = @_;
    my ($v) = @{$args}{'v'};
    return Muldis::DB::Engine::Example::Value::Blob->new({ 'v' => $v });
}

sub newText {
    my ($args) = @_;
    my ($v) = @{$args}{'v'};
    return Muldis::DB::Engine::Example::Value::Text->new({ 'v' => $v });
}

sub newQuasiTuple {
    my ($args) = @_;
    my ($v) = @{$args}{'v'};
    return Muldis::DB::Engine::Example::Value::QuasiTuple->new({
        'v' => $v });
}

sub newTuple {
    my ($args) = @_;
    my ($v) = @{$args}{'v'};
    return Muldis::DB::Engine::Example::Value::Tuple->new({ 'v' => $v });
}

sub newQuasiRelation {
    my ($args) = @_;
    my ($heading, $body) = @{$args}{'heading', 'body'};
    return Muldis::DB::Engine::Example::Value::QuasiRelation->new({
        'heading' => $heading, 'body' => $body });
}

sub newRelation {
    my ($args) = @_;
    my ($heading, $body) = @{$args}{'heading', 'body'};
    return Muldis::DB::Engine::Example::Value::Relation->new({
        'heading' => $heading, 'body' => $body });
}

###########################################################################

} # module Muldis::DB::Engine::Example::Value

###########################################################################
###########################################################################

{ package Muldis::DB::Engine::Example::Value::Universal; # role

    use Scalar::Util qw(blessed);

    my $ATTR_ROOT_TYPE = 'sys.Core.Universal.Universal::root_type';
        # Str.
        # This is the fundamental Muldis D data type that this ::Universal
        # object's implementation sees it as a generic member of, and which
        # generally determines what operators can be used with it.
        # It is a supertype of the declared type.
    my $ATTR_LAST_KNOWN_MST
        = 'sys.Core.Universal.Universal::last_known_mst';
        # Str.
        # This is the Muldis D data type that is the most specific type
        # of this ::Universal, as it was last determined.
        # Since calculating a value's mst may be expensive, this object
        # attribute may either be unset or be out of date with respect to
        # the current type system, that is, not be automatically updated at
        # the same time that a new subtype of its old mst is declared.

    my $ATTR_WHICH = 'sys.Core.Universal.Universal::which';
        # Str.
        # This is a unique identifier for the value that this object
        # represents that should compare correctly with the corresponding
        # identifiers of all ::Universal-doing objects.
        # It is a text string of format "<tnl> <tn> <vll> <vl>" where:
        #   1. <tn> is the value's root type name (fully qualified)
        #   2. <tnl> is the character-length of <tn>
        #   3. <vl> is the (class-determined) stringified value itself
        #   4. <vll> is the character-length of <vl>
        # This identifier is mainly used when a ::Universal needs to be
        # used as a key to index the ::Universal with, not necessarily when
        # comparing 2 values for is_equality.
        # This identifier can be expensive to calculate, so it will be done
        # only when actually required; eg, by the which() method.

###########################################################################

sub new {
    my ($class, $args) = @_;
    my $self = bless {}, $class;
    $self->Muldis::DB::Engine::Example::Value::Universal::_build();
    $self->_build( $args );
    return $self;
}

sub _build {
    my ($self) = @_;
    my $root_type = $self->_root_type();
    $self->{$ATTR_ROOT_TYPE} = $root_type;
    $self->{$ATTR_LAST_KNOWN_MST} = $root_type;
    $self->{$ATTR_WHICH} = undef;
    return;
}

###########################################################################

sub root_type {
    my ($self) = @_;
    return $self->{$ATTR_ROOT_TYPE};
}

sub last_known_mst {
    my ($self) = @_;
    return $self->{$ATTR_LAST_KNOWN_MST};
}

sub which {
    my ($self) = @_;
    if (!defined $self->{$ATTR_WHICH}) {
        my $rt = ''.$self->{$ATTR_ROOT_TYPE};
        my $len_rt = length $rt;
        my $main = $self->_which();
        my $len_main = length $main;
        $self->{$ATTR_WHICH} = "$len_rt $rt $len_main $main";
    }
    return $self->{$ATTR_WHICH};
}

###########################################################################

sub is_equal {
    my ($self, $args) = @_;
    my ($other) = @{$args}{'other'};
    return $BOOL_FALSE
        if blessed $other ne blessed $self;
    return $BOOL_FALSE
        if $other->{$ATTR_ROOT_TYPE} ne $self->{$ATTR_ROOT_TYPE};
    return $self->_is_equal( $other );
}

###########################################################################

} # role Muldis::DB::Engine::Example::Value::Universal

###########################################################################
###########################################################################

{ package Muldis::DB::Engine::Example::Value::Scalar; # role
    use base 'Muldis::DB::Engine::Example::Value::Universal';
} # role Muldis::DB::Engine::Example::Value::Scalar

###########################################################################
###########################################################################

{ package Muldis::DB::Engine::Example::Value::Bool; # class
    use base 'Muldis::DB::Engine::Example::Value::Scalar';

    my $ATTR_V = 'v';
        # A p5 Scalar that is_equals $BOOL_FALSE|$BOOL_TRUE.

###########################################################################

sub _build {
    my ($self, $args) = @_;
    my ($v) = @{$args}{'v'};
    $self->{$ATTR_V} = $v;
    return;
}

###########################################################################

sub _root_type {
    return 'sys.Core.Bool.Bool';
}

sub _which {
    my ($self) = @_;
    return ''.$self->{$ATTR_V};
}

###########################################################################

sub _is_equal {
    my ($self, $other) = @_;
    return $other->{$ATTR_V} eq $self->{$ATTR_V};
}

###########################################################################

sub v {
    my ($self) = @_;
    return $self->{$ATTR_V};
}

###########################################################################

} # class Muldis::DB::Engine::Example::Value::Bool

###########################################################################
###########################################################################

{ package Muldis::DB::Engine::Example::Value::Order; # class
    use base 'Muldis::DB::Engine::Example::Value::Scalar';

    my $ATTR_V = 'v';
        # A p5 Scalar that is_equals $ORDER_(INCREASE|SAME|DECREASE).

###########################################################################

sub _build {
    my ($self, $args) = @_;
    my ($v) = @{$args}{'v'};
    $self->{$ATTR_V} = $v;
    return;
}

###########################################################################

sub _root_type {
    return 'sys.Core.Order.Order';
}

sub _which {
    my ($self) = @_;
    return ''.$self->{$ATTR_V};
}

###########################################################################

sub _is_equal {
    my ($self, $other) = @_;
    return $other->{$ATTR_V} eq $self->{$ATTR_V};
}

###########################################################################

sub v {
    my ($self) = @_;
    return $self->{$ATTR_V};
}

###########################################################################

} # class Muldis::DB::Engine::Example::Value::Order

###########################################################################
###########################################################################

{ package Muldis::DB::Engine::Example::Value::Int; # class
    use base 'Muldis::DB::Engine::Example::Value::Scalar';

    my $ATTR_V = 'v';
        # A p5 Scalar that is a Perl integer or BigInt or canonical string.

###########################################################################

sub _build {
    my ($self, $args) = @_;
    my ($v) = @{$args}{'v'};
    $self->{$ATTR_V} = $v;
    return;
}

###########################################################################

sub _root_type {
    return 'sys.Core.Int.Int';
}

sub _which {
    my ($self) = @_;
    return ''.$self->{$ATTR_V};
}

###########################################################################

sub _is_equal {
    my ($self, $other) = @_;
    return $other->{$ATTR_V} == $self->{$ATTR_V};
}

###########################################################################

sub v {
    my ($self) = @_;
    return $self->{$ATTR_V};
}

###########################################################################

} # class Muldis::DB::Engine::Example::Value::Int

###########################################################################
###########################################################################

{ package Muldis::DB::Engine::Example::Value::Rat; # class
    use base 'Muldis::DB::Engine::Example::Value::Scalar';

    my $ATTR_V = 'v';
        # A p5 Scalar that is a Perl number or BigRat or canonical string.

###########################################################################

sub _build {
    my ($self, $args) = @_;
    my ($v) = @{$args}{'v'};
    $self->{$ATTR_V} = $v;
    return;
}

###########################################################################

sub _root_type {
    return 'sys.Core.Rat.Rat';
}

sub _which {
    my ($self) = @_;
    return ''.$self->{$ATTR_V};
}

###########################################################################

sub _is_equal {
    my ($self, $other) = @_;
    return $other->{$ATTR_V} == $self->{$ATTR_V};
}

###########################################################################

sub v {
    my ($self) = @_;
    return $self->{$ATTR_V};
}

###########################################################################

} # class Muldis::DB::Engine::Example::Value::Rat

###########################################################################
###########################################################################

{ package Muldis::DB::Engine::Example::Value::Blob; # class
    use base 'Muldis::DB::Engine::Example::Value::Scalar';

    my $ATTR_V = 'v';
        # A p5 Scalar that is a byte-mode string; it has false utf8 flag.

###########################################################################

sub _build {
    my ($self, $args) = @_;
    my ($v) = @{$args}{'v'};
    $self->{$ATTR_V} = $v;
    return;
}

###########################################################################

sub _root_type {
    return 'sys.Core.Blob.Blob';
}

sub _which {
    my ($self) = @_;
    return $self->{$ATTR_V};
}

###########################################################################

sub _is_equal {
    my ($self, $other) = @_;
    return $other->{$ATTR_V} eq $self->{$ATTR_V};
}

###########################################################################

sub v {
    my ($self) = @_;
    return $self->{$ATTR_V};
}

###########################################################################

} # class Muldis::DB::Engine::Example::Value::Blob

###########################################################################
###########################################################################

{ package Muldis::DB::Engine::Example::Value::Text; # class
    use base 'Muldis::DB::Engine::Example::Value::Scalar';

    my $ATTR_V = 'v';
        # A p5 Scalar that is a text-mode string;
        # it either has true utf8 flag or is only 7-bit bytes.

###########################################################################

sub _build {
    my ($self, $args) = @_;
    my ($v) = @{$args}{'v'};
    $self->{$ATTR_V} = $v;
    return;
}

###########################################################################

sub _root_type {
    return 'sys.Core.Text.Text';
}

sub _which {
    my ($self) = @_;
    return $self->{$ATTR_V};
}

###########################################################################

sub _is_equal {
    my ($self, $other) = @_;
    return $other->{$ATTR_V} eq $self->{$ATTR_V};
}

###########################################################################

sub v {
    my ($self) = @_;
    return $self->{$ATTR_V};
}

###########################################################################

} # class Muldis::DB::Engine::Example::Value::Text

###########################################################################
###########################################################################

{ package Muldis::DB::Engine::Example::Value::QuasiTuple; # class
    use base 'Muldis::DB::Engine::Example::Value::Universal';

    my $ATTR_V = 'v';
        # Hash; keys are attr names, values are attr values.

###########################################################################

sub _build {
    my ($self, $args) = @_;
    my ($v) = @{$args}{'v'};
    $self->{$ATTR_V} = $v;
    return;
}

###########################################################################

sub _root_type {
    return 'sys.Core.QuasiTuple.QuasiTuple';
}

sub _which {
    my ($self) = @_;
    my $v = $self->{$ATTR_V};
    return join q{ }, map {
            my $mk = (length $_) . q{ } . $_;
            my $mv = $v->{$_}->which();
            "K $mk V $mv";
        } sort keys %{$v};
}

###########################################################################

sub _is_equal {
    my ($self, $other) = @_;
    my $v1 = $self->{$ATTR_V};
    my $v2 = $other->{$ATTR_V};
    return $BOOL_FALSE
        if keys %{$v2} != keys %{$v1};
    for my $ek (keys %{$v1}) {
        return $BOOL_FALSE
            if !exists $v2->{$ek};
        return $BOOL_FALSE
            if !$v1->{$ek}->is_equal({ 'other' => $v2->{$ek} });
    }
    return $BOOL_TRUE;
}

###########################################################################

sub v {
    my ($self) = @_;
    return $self->{$ATTR_V};
}

###########################################################################

} # class Muldis::DB::Engine::Example::Value::QuasiTuple

###########################################################################
###########################################################################

{ package Muldis::DB::Engine::Example::Value::Tuple; # class
    use base 'Muldis::DB::Engine::Example::Value::QuasiTuple';

###########################################################################

sub _root_type {
    return 'sys.Core.Tuple.Tuple';
}

###########################################################################

} # class Muldis::DB::Engine::Example::Value::Tuple

###########################################################################
###########################################################################

{ package Muldis::DB::Engine::Example::Value::QuasiRelation; # class
    use base 'Muldis::DB::Engine::Example::Value::Universal';

    my $ATTR_HEADING      = 'heading';
        # Hash; keys are attr names, values are undef.
    my $ATTR_BODY         = 'body';
        # Array of Muldis::DB::Engine::Example::Value::QuasiTuple.
        # Each elem a tuple; keys are attr names, values are attr values.
    my $ATTR_KEY_OVER_ALL = 'key_over_all';
        # Hash of Muldis::DB::Engine::Example::Value::QuasiTuple.
        # Keys are the .WHICH of the values.

###########################################################################

sub _build {
    my ($self, $args) = @_;
    my ($heading, $body) = @{$args}{'heading', 'body'};

    my $key_over_all = {map { $_->which() => $_ } @{$body}}; # elim dup tpl

    $self->{$ATTR_HEADING}      = $heading;
    $self->{$ATTR_BODY}         = [values %{$key_over_all}]; # no dup in b
    $self->{$ATTR_KEY_OVER_ALL} = $key_over_all;

    return;
}

###########################################################################

sub _root_type {
    return 'sys.Core.QuasiRelation.QuasiRelation';
}

sub _which {
    my ($self) = @_;
    my $hs = join q{ }, map {
            (length $_) . q{ } . $_
        } sort keys %{$self->{$ATTR_HEADING}};
    my $bs = join q{ }, sort keys %{$self->{$ATTR_KEY_OVER_ALL}};
    return "H $hs B $bs";
}

###########################################################################

sub _is_equal {
    my ($self, $other) = @_;
    my $h1 = $self->{$ATTR_HEADING};
    my $h2 = $other->{$ATTR_HEADING};
    return $BOOL_FALSE
        if keys %{$h2} != keys %{$h1};
    for my $ek (keys %{$h1}) {
        return $BOOL_FALSE
            if !exists $h2->{$ek};
    }
    return $BOOL_FALSE
        if @{$other->{$ATTR_BODY}} != @{$self->{$ATTR_BODY}};
    my $b1 = $self->{$ATTR_KEY_OVER_ALL};
    my $b2 = $other->{$ATTR_KEY_OVER_ALL};
    for my $ek (keys %{$b1}) {
        return $BOOL_FALSE
            if !exists $b2->{$ek};
    }
    return $BOOL_TRUE;
}

###########################################################################

sub heading {
    my ($self) = @_;
    return $self->{$ATTR_HEADING};
}

sub body {
    my ($self) = @_;
    return $self->{$ATTR_BODY};
}

sub key_over_all {
    my ($self) = @_;
    return $self->{$ATTR_KEY_OVER_ALL};
}

###########################################################################

} # class Muldis::DB::Engine::Example::Value::QuasiRelation

###########################################################################
###########################################################################

{ package Muldis::DB::Engine::Example::Value::Relation; # class
    use base 'Muldis::DB::Engine::Example::Value::QuasiRelation';

###########################################################################

sub _root_type {
    return 'sys.Core.Relation.Relation';
}

###########################################################################

} # class Muldis::DB::Engine::Example::Value::Relation

###########################################################################
###########################################################################

1; # Magic true value required at end of a reusable file's code.
__END__

=pod

=encoding utf8

=head1 NAME

Muldis::DB::Engine::Example::Value -
Physical representations of all core data type values

=head1 VERSION

This document describes Muldis::DB::Engine::Example::Value version 0.0.0
for Perl 5.

It also describes the same-number versions for Perl 5 of [...].

=head1 DESCRIPTION

This file is used internally by L<Muldis::DB::Engine::Example>; it is not
intended to be used directly in user code.

It provides physical representations of data type values that this Example
Engine uses to implement Muldis D.  The API of these is expressly not
intended to match the API that the language itself specifies as possible
representations for system-defined data types.

Specifically, this file represents the core system-defined data types that
all Muldis D implementations must have, namely: Bool, Order, Int, Rat,
Blob, Text, Tuple, Relation, QuasiTuple, QuasiRelation, and the Cat.*
types.

By contrast, the optional data types are given physical representations by
other files: L<Muldis::DB::Engine::Example::Value::Temporal>,
L<Muldis::DB::Engine::Example::Value::Spatial>.

=head1 BUGS AND LIMITATIONS

This file assumes that it will only be invoked by other components of
Example, and that they will only be feeding it arguments that are exactly
what it requires.  For reasons of performance, it does not do any of its
own basic argument validation, as doing so should be fully redundant.  Any
invoker should be validating any arguments that it in turn got from user
code.  Moreover, this file will often take or return values by reference,
also for performance, and the caller is expected to know that they should
not be modifying said then-shared values afterwards.

=head1 AUTHOR

Darren Duncan (C<perl@DarrenDuncan.net>)

=head1 LICENSE AND COPYRIGHT

This file is part of the Muldis DB framework.

Muldis DB is Copyright © 2002-2008, Darren Duncan.

See the LICENSE AND COPYRIGHT of L<Muldis::DB> for details.

=head1 ACKNOWLEDGEMENTS

The ACKNOWLEDGEMENTS in L<Muldis::DB> apply to this file too.

=cut
