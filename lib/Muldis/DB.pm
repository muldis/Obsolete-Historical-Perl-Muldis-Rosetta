use 5.008001;
use utf8;
use strict;
use warnings FATAL => 'all';

use QDRDBMS::AST;

###########################################################################
###########################################################################

{ package QDRDBMS; # module
    our $VERSION = 0.000000;
    # Note: This given version applies to all of this file's packages.

###########################################################################

sub new_dbms {
    my ($args) = @_;
    my ($engine_name, $dbms_config)
        = @{$args}{'engine_name', 'dbms_config'};
    return QDRDBMS::Interface::DBMS->new({
        'engine_name' => $engine_name, 'dbms_config' => $dbms_config });
}

###########################################################################

} # module QDRDBMS

###########################################################################
###########################################################################

{ package QDRDBMS::Interface::DBMS; # class

    use Carp;
    use Encode qw(is_utf8);
    use Scalar::Util qw(blessed);

    my $ATTR_DBMS_ENG = 'dbms_eng';

###########################################################################

sub new {
    my ($class, $args) = @_;
    my $self = bless {}, $class;
    my ($engine_name, $dbms_config)
        = @{$args}{'engine_name', 'dbms_config'};

    confess q{new(): Bad :$engine_name arg; Perl 5 does not consider}
            . q{ it to be a character string, or it is the empty string.}
        if !defined $engine_name or $engine_name eq q{}
            or (!is_utf8 $engine_name
                and $engine_name =~ m/[^\x00-\x7F]/xs);

    # A class may be loaded due to it being embedded in a non-excl file.
    if (!do {
            no strict 'refs';
            defined %{$engine_name . '::'};
        }) {
        # Note: We have to invoke this 'require' in an eval string
        # because we need the bareword semantics, where 'require'
        # will munge the module name into file system paths.
        eval "require $engine_name;";
        if (my $err = $@) {
            confess q{new(): Could not load QDRDBMS Engine class}
                . qq{ '$engine_name': $err};
        }
        confess qq{new(): Could not load QDRDBMS Engine class}
                . qq{ '$engine_name': while that file did compile without}
                . q{ errors, it did not declare the same-named class.}
            if !do {
                no strict 'refs';
                defined %{$engine_name . '::'};
            };
    }
    confess qq{new(): The QDRDBMS root Engine class '$engine_name' is not}
            . q{ a QDRDBMS::Engine::Role-doing class.}
        if !$engine_name->isa( 'QDRDBMS::Engine::Role' );
    my $dbms_eng = eval {
        $engine_name->new_dbms({ 'dbms_config' => $dbms_config });
    };
    if (my $err = $@) {
        confess qq{new(): The QDRDBMS Engine class '$engine_name' threw}
            . qq{ an exception during its new_dbms() execution: $err};
    }
    confess q{new(): The new_dbms() constructor submethod of the QDRDBMS}
            . qq{ root Engine class '$engine_name' did not return an}
            . q{ object of a QDRDBMS::Engine::Role::DBMS-doing class.}
        if !blessed $dbms_eng
            or !$dbms_eng->isa( 'QDRDBMS::Engine::Role::DBMS' );

    $self->{$ATTR_DBMS_ENG} = $dbms_eng;

    return $self;
}

###########################################################################

sub new_var {
    my ($self, $args) = @_;
    my ($decl_type) = @{$args}{'decl_type'};
    return QDRDBMS::Interface::HostGateVar->new({
        'dbms' => $self, 'decl_type' => $decl_type });
}

sub prepare {
    my ($self, $args) = @_;
    my ($rtn_ast) = @{$args}{'rtn_ast'};
    return QDRDBMS::Interface::HostGateRtn->new({
        'dbms' => $self, 'rtn_ast' => $rtn_ast });
}

###########################################################################

} # class QDRDBMS::Interface::DBMS

###########################################################################
###########################################################################

{ package QDRDBMS::Interface::HostGateVar; # class

    use Carp;
    use Scalar::Util qw(blessed);

    my $ATTR_DBMS    = 'dbms';
    my $ATTR_VAR_ENG = 'var_eng';

    my $DBMS_ATTR_DBMS_ENG = 'dbms_eng';

###########################################################################

sub new {
    my ($class, $args) = @_;
    my $self = bless {}, $class;
    my ($dbms, $decl_type) = @{$args}{'dbms', 'decl_type'};

    confess q{new(): Bad :$dbms arg; it is not an object of a}
            . q{ QDRDBMS::Interface::DBMS-doing class.}
        if !blessed $dbms or !$dbms->isa( 'QDRDBMS::Interface::DBMS' );
    my $dbms_eng = $dbms->{$DBMS_ATTR_DBMS_ENG};
    my $dbms_eng_class = blessed $dbms_eng;

    confess q{new(): Bad :$decl_type arg; it is not an object of a}
            . q{ QDRDBMS::AST::TypeInvo-doing class.}
        if !blessed $decl_type
            or !$decl_type->isa( 'QDRDBMS::AST::TypeInvo' );

    my $var_eng = eval {
        $dbms_eng->new_var({ 'decl_type' => $decl_type });
    };
    if (my $err = $@) {
        confess qq{new(): The QDRDBMS DBMS Engine class '$dbms_eng_class'}
            . q{ threw an exception during its new_var()}
            . qq{ execution: $err};
    }
    confess q{new(): The new_var() method of the QDRDBMS}
            . qq{ DBMS class '$dbms_eng_class' did not return an object}
            . q{ of a QDRDBMS::Engine::Role::HostGateVar-doing class.}
        if !blessed $var_eng
            or !$var_eng->isa( 'QDRDBMS::Engine::Role::HostGateVar' );

    $self->{$ATTR_DBMS}    = $dbms;
    $self->{$ATTR_VAR_ENG} = $var_eng;

    return $self;
}

###########################################################################

sub fetch_ast {
    my ($self) = @_;

    my $var_eng = $self->{$ATTR_VAR_ENG};
    my $val_ast = eval {
        $var_eng->fetch_ast();
    };
    if (my $err = $@) {
        my $var_eng_class = blessed $var_eng;
        confess q{fetch_ast(): The QDRDBMS HostGateVar Engine}
            . qq{ class '$var_eng_class' threw an exception during its}
            . qq{ fetch_ast() execution: $err};
    }

    return $val_ast;
}

###########################################################################

sub store_ast {
    my ($self, $args) = @_;
    my ($val_ast) = @{$args}{'val_ast'};

    confess q{store_ast(): Bad :$val_ast arg; it is not an object of a}
            . q{ QDRDBMS::AST::Node-doing class.}
        if !blessed $val_ast or !$val_ast->isa( 'QDRDBMS::AST::Node' );

    my $var_eng = $self->{$ATTR_VAR_ENG};
    eval {
        $var_eng->store_ast({ 'val_ast' => $val_ast });
    };
    if (my $err = $@) {
        my $var_eng_class = blessed $var_eng;
        confess q{store_ast(): The QDRDBMS HostGateVar Engine}
            . qq{ class '$var_eng_class' threw an exception during its}
            . qq{ store_ast() execution: $err};
    }

    return;
}

###########################################################################

} # class QDRDBMS::Interface::HostGateVar

###########################################################################
###########################################################################

{ package QDRDBMS::Interface::HostGateRtn; # class

    use Carp;
    use Scalar::Util qw(blessed);

    my $ATTR_DBMS    = 'dbms';
    my $ATTR_RTN_AST = 'rtn_ast';
    my $ATTR_RTN_ENG = 'rtn_eng';

    my $DBMS_ATTR_DBMS_ENG     = 'dbms_eng';
    my $VAR_ATTR_VAR_ENG       = 'var_eng';
    my $ASTHGR_ATTR_UPD_PARAMS = 'upd_params';
    my $ASTHGR_ATTR_RO_PARAMS  = 'ro_params';
    my $TYPEDICT_ATTR_MAP_HOA  = 'map_hoa';

###########################################################################

sub new {
    my ($class, $args) = @_;
    my $self = bless {}, $class;
    my ($dbms, $rtn_ast) = @{$args}{'dbms', 'rtn_ast'};

    confess q{new(): Bad :$dbms arg; it is not an object of a}
            . q{ QDRDBMS::Interface::DBMS-doing class.}
        if !blessed $dbms or !$dbms->isa( 'QDRDBMS::Interface::DBMS' );
    my $dbms_eng = $dbms->{$DBMS_ATTR_DBMS_ENG};
    my $dbms_eng_class = blessed $dbms_eng;

    confess q{new(): Bad :$rtn_ast arg; it is not an object of a}
            . q{ QDRDBMS::AST::HostGateRtn-doing class.}
        if !blessed $rtn_ast
            or !$rtn_ast->isa( 'QDRDBMS::AST::HostGateRtn' );

    my $rtn_eng = eval {
        $dbms_eng->prepare({ 'rtn_ast' => $rtn_ast });
    };
    if (my $err = $@) {
        confess qq{new(): The QDRDBMS DBMS Engine class '$dbms_eng_class'}
            . qq{ threw an exception during its prepare() execution: $err};
    }
    confess q{new(): The prepare() method of the QDRDBMS}
            . qq{ DBMS class '$dbms_eng_class' did not return an object}
            . q{ of a QDRDBMS::Engine::Role::HostGateRtn-doing class.}
        if !blessed $rtn_eng
            or !$rtn_eng->isa( 'QDRDBMS::Engine::Role::HostGateRtn' );

    $self->{$ATTR_DBMS}    = $dbms;
    $self->{$ATTR_RTN_AST} = $rtn_ast;
    $self->{$ATTR_RTN_ENG} = $rtn_eng;

    return $self;
}

###########################################################################

sub bind_host_params {
    my ($self, $args) = @_;
    my ($upd_args, $ro_args) = @{$args}{'upd_args', 'ro_args'};

    my $exp_upd_args_map_hoa = $self->{$ATTR_RTN_AST
        }->{$ASTHGR_ATTR_UPD_PARAMS}->{$TYPEDICT_ATTR_MAP_HOA};
    my $exp_ro_args_map_hoa = $self->{$ATTR_RTN_AST
        }->{$ASTHGR_ATTR_RO_PARAMS}->{$TYPEDICT_ATTR_MAP_HOA};

    confess q{bind_host_params(): Bad :$upd_args arg; it is not an Array.}
        if ref $upd_args ne 'ARRAY';
    my $seen_upd_param_names = {};
    my $upd_arg_engs = [];
    for my $elem (@{$upd_args}) {
        confess q{bind_host_params(): Bad :$upd_args arg elem; it is not a}
                . q{ 2-element Array.}
            if ref $elem ne 'ARRAY' or @{$elem} != 2;
        my ($param_name, $var_intf) = @{$elem};
        confess q{bind_host_params(): Bad :$upd_args arg elem; its first}
                . q{ element is not an object of a}
                . q{ QDRDBMS::AST::EntityName-doing class.}
            if !blessed $param_name
                or !$param_name->isa( 'QDRDBMS::AST::EntityName' );
        my $param_name_text = $param_name->text();
        confess q{bind_host_params(): Bad :$upd_args arg elem; its first}
                . q{ element does not match the name of a}
                . q{ subject-to-update routine param.}
            if !exists $exp_upd_args_map_hoa->{$param_name_text};
        confess q{bind_host_params(): Bad :$vars arg elem; its first elem}
                . q{ is not distinct between the arg elems.}
            if exists $seen_upd_param_names->{$param_name_text};
        $seen_upd_param_names->{$param_name_text} = 1;
        confess q{bind_host_params(): Bad :$upd_args arg elem; its second}
                . q{ element is not an object of a}
                . q{ QDRDBMS::Interface::HostGateVar-doing class.}
            if !blessed $var_intf
                or !$var_intf->isa( 'QDRDBMS::Interface::HostGateVar' );
        push @{$upd_arg_engs},
            [$param_name, $var_intf->{$VAR_ATTR_VAR_ENG}];
    }

    confess q{bind_host_params(): Bad :$ro_args arg; it is not an Array.}
        if ref $ro_args ne 'ARRAY';
    my $seen_ro_param_names = {};
    my $ro_arg_engs = [];
    for my $elem (@{$ro_args}) {
        confess q{bind_host_params(): Bad :$ro_args arg elem; it is not a}
                . q{ 2-element Array.}
            if ref $elem ne 'ARRAY' or @{$elem} != 2;
        my ($param_name, $var_intf) = @{$elem};
        confess q{bind_host_params(): Bad :$ro_args arg elem; its first}
                . q{ element is not an object of a}
                . q{ QDRDBMS::AST::EntityName-doing class.}
            if !blessed $param_name
                or !$param_name->isa( 'QDRDBMS::AST::EntityName' );
        my $param_name_text = $param_name->text();
        confess q{bind_host_params(): Bad :$ro_args arg elem; its first}
                . q{ element does not match the name of a}
                . q{ read-only routine param.}
            if !exists $exp_ro_args_map_hoa->{$param_name_text};
        confess q{bind_host_params(): Bad :$vars arg elem; its first elem}
                . q{ is not distinct between the arg elems.}
            if exists $seen_ro_param_names->{$param_name_text};
        $seen_ro_param_names->{$param_name_text} = 1;
        confess q{bind_host_params(): Bad :$ro_args arg elem; its second}
                . q{ element is not an object of a}
                . q{ QDRDBMS::Interface::HostGateVar-doing class.}
            if !blessed $var_intf
                or !$var_intf->isa( 'QDRDBMS::Interface::HostGateVar' );
        push @{$ro_arg_engs},
            [$param_name, $var_intf->{$VAR_ATTR_VAR_ENG}];
    }

    my $rtn_eng = $self->{$ATTR_RTN_ENG};
    eval {
        $rtn_eng->bind_host_params({
            'upd_args' => $upd_arg_engs, 'ro_args' => $ro_arg_engs });
    };
    if (my $err = $@) {
        my $rtn_eng_class = blessed $rtn_eng;
        confess q{bind_host_params(): The QDRDBMS HostGateRtn Engine}
            . qq{ class '$rtn_eng_class' threw an exception during its}
            . qq{ bind_host_params() execution: $err};
    }

    return;
}

###########################################################################

sub execute {
    my ($self) = @_;
    my $rtn_eng = $self->{$ATTR_RTN_ENG};
    eval {
        $rtn_eng->execute();
    };
    if (my $err = $@) {
        my $rtn_eng_class = blessed $rtn_eng;
        confess q{execute(): The QDRDBMS HostGateRtn Engine}
            . qq{ class '$rtn_eng_class' threw an exception during its}
            . qq{ execute() execution: $err};
    }
    return;
}

###########################################################################

} # class QDRDBMS::Interface::HostGateRtn

###########################################################################
###########################################################################

{ package QDRDBMS::Engine::Role; # role
    use Carp;

    sub new_dbms {
        my ($class) = @_;
        confess q{not implemented by subclass } . $class;
    }

} # role QDRDBMS::Engine::Role

###########################################################################
###########################################################################

{ package QDRDBMS::Engine::Role::DBMS; # role
    use Carp;
    use Scalar::Util qw(blessed);

    sub new_var {
        my ($self) = @_;
        confess q{not implemented by subclass } . (blessed $self);
    }

    sub prepare {
        my ($self) = @_;
        confess q{not implemented by subclass } . (blessed $self);
    }

} # role QDRDBMS::Engine::Role::DBMS

###########################################################################
###########################################################################

{ package QDRDBMS::Engine::Role::HostGateVar; # role
    use Carp;
    use Scalar::Util qw(blessed);

    sub fetch_ast {
        my ($self) = @_;
        confess q{not implemented by subclass } . (blessed $self);
    }

    sub store_ast {
        my ($self) = @_;
        confess q{not implemented by subclass } . (blessed $self);
    }

} # role QDRDBMS::Engine::Role::HostGateVar

###########################################################################
###########################################################################

{ package QDRDBMS::Engine::Role::HostGateRtn; # role
    use Carp;
    use Scalar::Util qw(blessed);

    sub bind_host_params {
        my ($self) = @_;
        confess q{not implemented by subclass } . (blessed $self);
    }

    sub execute {
        my ($self) = @_;
        confess q{not implemented by subclass } . (blessed $self);
    }

} # role QDRDBMS::Engine::Role::HostGateRtn

###########################################################################
###########################################################################

1; # Magic true value required at end of a reusable file's code.
__END__

=pod

=encoding utf8

=head1 NAME

QDRDBMS -
Full-featured truly relational DBMS in Perl

=head1 VERSION

This document describes QDRDBMS version 0.0.0 for Perl 5.

It also describes the same-number versions for Perl 5 of
QDRDBMS::Interface::DBMS ("DBMS"), QDRDBMS::Interface::HostGateVar
("HostGateVar"), and QDRDBMS::Interface::HostGateRtn ("HostGateRtn").

It also describes the same-number versions for Perl 5 of
QDRDBMS::Engine::Role, QDRDBMS::Engine::Role::DBMS,
QDRDBMS::Engine::Role::HostGateVar, and QDRDBMS::Engine::Role::HostGateRtn.

I<Warning:  The C<QDRDBMS> name was intentionally picked to be temporary
(it should evoke "QDOS"), since the current release is a prototype.  In the
future, when QDRDBMS has matured significantly, it is expected that it will
be renamed again to a permanent long-term name, so you should take
appropriate precautions that would ease your migration later.  This is
guaranteed to happen prior to it reaching version 1.0.0.  See the README
file of the QDRDBMS distribution for more information.>

=head1 SYNOPSIS

    use QDRDBMS;

    # Instantiate a QDRDBMS DBMS / virtual machine.
    my $dbms = QDRDBMS::new_dbms({
            'engine_name' => 'QDRDBMS::Engine::Example',
            'dbms_config' => {},
        });

    # TODO: Create or connect to a repository and work with it.

I<This documentation is pending.>

=head1 DESCRIPTION

The "QDRDBMS" DBMS framework is a powerful but elegant system, which makes
it easy to create and use relational databases in a very reliable,
portable, and efficient way.  This "QDRDBMS" file is the core of the
QDRDBMS framework and defines a truly relational common programmatic
interface (API), called the QDRDBMS Native Interface, which applications
invoke and which multiple interchangeable "Engine" back-ends (usually
provided by third parties) implement.  This interface is rigorously
defined, such that there should be no ambiguity when trying to invoke or
implement it, and so an application written to it should behave identically
no matter which conforming "Engine" is in use.

QDRDBMS incorporates a complete and uncompromising implementation of "The
Third Manifesto" (TTM), a formal proposal by Christopher J. Date and Hugh
Darwen for a solid foundation for data and database management systems
(DBMSs); like Edgar F. Codd's original papers, TTM can be seen as an
abstract blueprint for the design of a DBMS and the language interface to
such a DBMS.  The main web site for TTM is
L<http://www.thethirdmanifesto.com/>, and its authors have also written
several books and papers and taught classes on the subject over the last
35+ years, along with Codd himself (some are listed in the
L<QDRDBMS::SeeAlso> documentation file).  Note that the QDRDBMS
documentation will be focusing mainly on how QDRDBMS itself works, and will
not spend much time in providing rationale; you can read TTM itself and
various other external documentation for much of that.

The QDRDBMS Native Interface is defined mainly in terms of a new high-level
programming language named "QDRDBMS D", which is computationally complete
(and industrial strength) and has fully integrated database functionality;
this language, which satisfies TTM's definition of a "D" language, is
described fully in the L<QDRDBMS::Language> documentation file that comes
with this "QDRDBMS" distribution.

While it is possible that one could write a self-contained application in
QDRDBMS D and compile that into its own executable, in practice one would
normally just write some components of their application in QDRDBMS D (as
either named modules or anonymous routines) and write the rest of the
application in their other language(s) of choice.  Assuming the main
application is written in Perl, it is this "QDRDBMS" file which provides
the glue between your Perl code and your QDRDBMS D code; "QDRDBMS"
implements a virtual machine that is embedded in your Perl application and
in which the QDRDBMS D code runs (it is analogous to the Perl interpreter
itself, which provides a virtual machine in which Perl code runs).

The classes and methods of this "QDRDBMS" file, together with those of
L<QDRDBMS::AST>, define the balance of the QDRDBMS Native Interface.  A
QDRDBMS::Interface::DBMS object represents a single active QDRDBMS virtual
machine; it has a spartan DBI-inspired set of methods which you use to
compile/prepare and/or invoke/execute QDRDBMS D statements and routines
within the virtual machine, input data to it, and output data from it.

You can create more than one DBMS object at a time, and they are
essentially all isolated from each other, even if more than one uses the
same Engine class to implement it; that is, multiple DBMS objects will not
have references to each other at a level visible in the QDRDBMS Native
Interface, if at all.  To account for situations where multiple DBMS
objects want to use the same external resources, such as a repository file
on disk, it is expected that the Engines will employ appropriate measures
such as system-managed locks so that resource corruption or application
failure is prevented.  I<Also, QDRDBMS should be thread safe and/or savvy
in the future, but for now it officially is not and you should not share
QDRDBMS objects between multiple threads, nor have objects in separate
threads try to access the same external resources.>

QDRDBMS does not use any dialect of SQL in its native API (unlike many
other DBMS products) because SQL is more ambiguous and error-prone to use,
and it is less expressive.  While QDRDBMS D is very different from SQL, it
is fully capable of modeling anything in the real world accurately, and it
can support a complete SQL emulation layer on top of it, so that your
legacy applications can be migrated to use the QDRDBMS DBMS with little
trouble.  Likewise, emulation layers for any other programming language can
be supported, such as Tutorial D or XQuery or FoxPro or dBase.

One distinctive feature of a QDRDBMS DBMS (compared to a typical other
vendor's DBMS) is that data definition statements are structured as
standard data manipulation statements but that the target relation
variables are system catalog relation variables rather than user-defined
relation variables.  In SQL terms, you create or alter tables by adding or
updating their "information schema" records, which in SQL are read-only,
not by using special 'create' or 'alter' statements.

Each QDRDBMS Engine has the complete freedom to implement the QDRDBMS DBMS
and QDRDBMS D however it likes; all QDRDBMS cares about is that the user
interface and behaviour conform to its preconceptions.

L<QDRDBMS::Engine::Example> is the self-contained and pure-Perl reference
implementation of an Engine and is included in the "QDRDBMS" core
distribution to allow the core to be completely testable on its own.  It is
coded intentionally in a simple fashion so that it is easy to maintain and
and easy for developers to study.  As a result, while it performs correctly
and reliably, it also performs quite slowly; you should only use Example
for testing, development, and study; you should not use it in production.

For production use, there should be a wide variety of third party Engine
modules that become available over time.  One plan being favored is that
the new (under development) enterprise-strength and Perl implemented
database server named L<Genezzo> (see also L<http://www.genezzo.com/>) will
evolve to implement the QDRDBMS DBMS natively, and be I<the> back-end which
is recommended above all others for production use.

Most of the other (near term) third party Engines will likely just map
QDRDBMS's rigorously defined API onto a pre-existing quasi-relational
database manager (such as SQLite, PostgreSQL, MySQL, Firebird, Teradata,
Oracle, Sybase, SQL Server, Informix, DB2, OpenBase, FrontBase, etc).
Given this fact, QDRDBMS's most prominent feature is that it provides a
common API for access to those databases, each of which takes a different
SQL or quasi-SQL dialect.  An application written to it should easily port
to alternative relational database engines with minimal effort.

This might seem strange to somebody who has not tried to port between
databases before, especially given that the Perl DBI purports to provide
"Database Independence".  However, the level of DBI's provided independence
is I<Database Driver Independence>, and not I<Database Language
Independence>.  To further demonstrate the difference, it is useful to
compare the DBI and QDRDBMS.  I<Such documentation is currently absent.>

=head1 FEATURE SUPPORT VALIDATION

The QDRDBMS Native Interface declares accessors for a large number of
actual or possible database features, any of which your application can
invoke, and all of which each QDRDBMS Engine would ideally implement or
interface to.

In reality, however, all Engines or underlying databases probably don't
support some features, and if your application tries to invoke any of the
same features that an Engine you are using doesn't support, then you will
have problems ranging from immediate crashes/exceptions to subtle data
corruption over time.

As an official quality assurance (QA) measure, QDRDBMS provides a means for
each Engine to programmatically declare which features it does and does not
support, so that code using that Engine will know so in advance of trying
to use said features.  Feature support declarations are typically coarse
grained and lump closely similar things together, for simplicity; they will
be just as fine grained as necessary and no finer (this can be changed over
time).  See the C<features()> method, which is how you read the
declarations.

One benefit of this QA feature is that, after you have written your
application and it is working with one Engine/database, and you want to
move it to a different Engine/database, you can determine at a glance which
alternatives also support the features you are using.  Note that, generally
speaking, you would have to be using very proprietary features to begin
with in order for the majority of QDRDBMS Engines/databases to not support
the application outright.

Another benefit of this QA feature is that there can be made a common
comprehensive test suite to run against all Engines in order to tell that
they are implementing the QDRDBMS interface properly or not; said test
suite will be smart enough to only test each Engine's compliance for those
features that the Engine claims to support, and not fail it for non-working
features that it explicitly says it doesn't support.  This common test
suite will save each Engine maker from having to write their own module
tests.  It would be used similarly to how Sun has an official validation
suite for Java Virtual Machines to make sure they implement the official
Java specification.  Please see the L<QDRDBMS::Validator> module(s), which
implements this test suite.

=head1 INTERFACE

The interface of QDRDBMS is fundamentally object-oriented; you use it by
creating objects from its member classes, usually invoking C<new()> on the
appropriate class name, and then invoking methods on those objects.  All of
their attributes are private, so you must use accessor methods.

QDRDBMS also provides the not-exportable wrapper subroutine
C<QDRDBMS::new_dbms> for the C<QDRDBMS::Interface::DBMS> constructor, which
has identical parameters, and exists solely as syntactic sugar.  Similarly,
the C<DBMS> methods C<new_var> and C<prepare> exist purely as syntactic
sugar over the C<HostGateVar> and C<HostGateRtn> constructors.  I<TODO:
Reimplement these as lexical aliases or compile-time macros instead, to
avoid the overhead of extra routine calls.>

The usual way that QDRDBMS indicates a failure is to throw an exception;
most often this is due to invalid input.  If an invoked routine simply
returns, you can assume that it has succeeded, even if the return value is
undefined.

=head2 The QDRDBMS::Interface::DBMS Class

I<This documentation is pending.>

=head2 The QDRDBMS::Interface::HostGateVar Class

I<This documentation is pending.>

=head2 The QDRDBMS::Interface::HostGateRtn Class

I<This documentation is pending.>

=head2 The QDRDBMS::Engine::Role(|::\w+) Roles

This "QDRDBMS" file also defines a few roles that the public interface
classes of all Engine modules must implement, and explicitly declare that
they are doing so.

The initial Engine class, which users specify in the C<$engine_name>
argument to the C<QDRDBMS::Interface::DBMS> constructor, must compose the
C<QDRDBMS::Engine::Role>, and implement the C<new_dbms> submethod.  The
DBMS Engine object returned by C<new_dbms> must compose the
C<QDRDBMS::Engine::Role::DBMS> role, and implement the methods C<new_var>
and C<prepare>.  The HostGateVar Engine object returned by C<new_var> must
compose the C<QDRDBMS::Engine::Role::HostGateVar> role, and implement the
methods C<fetch_ast> and C<store_ast>.  The HostGateRtn Engine object
returned by C<new_var> must compose the
C<QDRDBMS::Engine::Role::HostGateRtn> role, and implement the methods
C<bind_host_params> and C<execute>.

The QDRDBMS Interface classes don't just validate user input on behalf of
Engines (allowing them to be simpler), but they also validate each
requested Engine's APIs and results, to some extent, on behalf of users (so
an application can more gracefully handle a bad Engine); the Engine Role
roles exist to help with the latter kind of validation, and they mainly
just declare shims for the required (sub|)methods, which die on invocation
if the Engine didn't declare its own versions; they don't presently contain
any actual functionality for Engines to use.

=head1 DIAGNOSTICS

I<This documentation is pending.>

=head1 CONFIGURATION AND ENVIRONMENT

I<This documentation is pending.>

=head1 DEPENDENCIES

This file requires any version of Perl 5.x.y that is at least 5.8.1.

It also requires these Perl 5 classes that are in the current distribution:
L<QDRDBMS::AST-(0.0.0)|QDRDBMS::AST>.

=head1 INCOMPATIBILITIES

None reported.

=head1 SEE ALSO

These documentation files are included in the QDRDBMS distribution:
L<QDRDBMS::Language>.

The Perl 5 module L<QDRDBMS::Validator> is bundled with QDRDBMS and can be
used to test QDRDBMS Engines.

The Perl 5 module L<QDRDBMS::Engine::Example> is bundled with QDRDBMS and
implements a self-contained reference implementation of a QDRDBMS Engine.

Go to the L<QDRDBMS::SeeAlso> file for the majority of external references.

=head1 BUGS AND LIMITATIONS

The QDRDBMS framework for Perl 5 is built according to certain old-school
or traditional Perl-5-land design principles, including that there are no
explicit attempts in code to enforce privacy of the framework's internals,
besides not documenting them as part of the public API.  (The QDRDBMS
framework for Perl 6 is different.)  That said, you should still respect
that privacy and just use the public API that QDRDBMS provides.  If you
bypass the public API anyway, as Perl 5 allows, you do so at your own
peril.

I<This documentation is pending.>

=head1 AUTHOR

Darren Duncan (C<perl@DarrenDuncan.net>)

=head1 LICENSE AND COPYRIGHT

This file is part of the QDRDBMS framework.

QDRDBMS is Copyright © 2002-2007, Darren Duncan.  All rights reserved.

QDRDBMS is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License (GPL) as published by the Free
Software Foundation (L<http://www.fsf.org/>); either version 3 of the
License, or (at your option) any later version.  You should have received a
copy of the GPL as part of the QDRDBMS distribution, in the file named
"GPL"; if not, see L<http://www.gnu.org/licenses> or write to the Free
Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301 USA.

I<WARNING:  The GPL version 3 is still being drafted; the publication of
its final version is expected on Friday, June 29, 2007; until then, that
license can not actually be used.  So the previous paragraph just
represents what the license of QDRDBMS is anticipated to be following an
explicit post June 29th re-distribution of it by the copyright holder.  If
you are seeing QDRDBMS prior to that re-distribution, for any reason or in
any place, then you should consider it as not being licensed at all, and
vanilla copyright law applies.  That said, QDRDBMS is hereby licensed to
you under the following proprietary terms:  You may copy, examine, modify,
and execute QDRDBMS, for the purpose of study or evaluation, during only
the time period prior to July 1st of 2007, after which time all privileges
granted to you under this proprietary license expire.  You should then be
able to acquire a subsequent QDRDBMS release that is licensed with the
GPL version 3.>

Linking QDRDBMS statically or dynamically with other components is making a
combined work based on QDRDBMS.  Thus, the terms and conditions of the GPL
cover the whole combination.  However, if it is not feasible for your
combined work to be distributed subject to the GPL, then the copyright
holders of QDRDBMS can sell you an appropriate proprietary license, so that
it is still possible for you to employ QDRDBMS to meet your needs.

For more information on matters such as licensing, including rationale, see
also the L<QDRDBMS::Copying> file that comes with QDRDBMS.

Any versions of QDRDBMS that you modify and distribute must carry prominent
notices stating that you changed the files and the date of any changes, in
addition to preserving this original copyright notice and other credits.
QDRDBMS is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  However, for an additional fee, the copyright
holders of QDRDBMS can sell you a warranty for it.

While it is by no means required, the copyright holders of QDRDBMS would
appreciate being informed any time you create a modified version of QDRDBMS
that you are willing to distribute, because that is a practical way of
suggesting improvements to the standard version.

=head1 ACKNOWLEDGEMENTS

None yet.

=head1 FORUMS

Several public email-based forums for QDRDBMS now exist, all of which you
can reach via L<http://mm.DarrenDuncan.net/mailman/listinfo>; go there to
manage your subscriptions to, or view the archives of, the following:

=over

=item C<qdrdbms-announce@mm.DarrenDuncan.net>

This low-volume list is mainly for official announcements from the QDRDBMS
developers, though developers of QDRDBMS extensions can also post their
announcements here.  This is not a discussion list.

=item C<qdrdbms-users@mm.DarrenDuncan.net>

This list is for general discussion among people who are using QDRDBMS,
which is not concerned with the implementation of QDRDBMS itself.  This is
the best place to ask for basic help in getting QDRDBMS installed on your
machine or to make it do what you want.  You could also submit feature
requests or report perceived bugs here, if you don't want to use CPAN's RT
system.

=item C<qdrdbms-devel@mm.DarrenDuncan.net>

This list is for discussion among people who are designing or implementing
the QDRDBMS core API (including QDRDBMS D language design), or who are
implementing QDRDBMS Engines, or who are writing core documentation, tests,
or examples.  It is not the place for non-implementers to get help in using
said.

=back

An official IRC channel for QDRDBMS is also intended, but not yet started.

Alternately, you can purchase more advanced commercial support for QDRDBMS
from its author; contact C<perl@DarrenDuncan.net> for details.

=cut