#!/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;

use File::Slurp             ();
use File::Temp ();
use FindBin ();

use base 'Test::Class';

use constant FIND_UNUSED_SUBS => $FindBin::Bin.q{/../find_unused_subs};

if ( !caller ) {
    my $test_obj = __PACKAGE__->new();
    plan tests => $test_obj->expected_tests();
    $test_obj->runtests();
}

sub _clear_homedir : Tests(startup) {
    my ($self) = @_;

    $self->{'tmp'} = File::Temp->new();

    return;
}

# ------------------------------------------------------------

sub test_basic : Tests(2) {

    ok -x FIND_UNUSED_SUBS, "binary exists";
    like run_find_unused_subs('--help'), qr{^Sample usages}m, 'help';

    return;
}

sub test_simple : Tests(5) {
    my $self = shift;
    cmp_bag $self->find_unused_subs_for( fixture_simple(), '--no-pack' ), [ map { 'main::' . $_ } qw{e f g} ];

    cmp_bag $self->find_unused_subs_for( fixture_simple('a'), '--no-pack' ), [ map { 'main::' . $_ } 'b' .. 'g' ], 'call a';
    cmp_bag $self->find_unused_subs_for( fixture_simple('b'), '--no-pack' ), [ map { 'main::' . $_ } 'c' .. 'g' ], 'call b';
    cmp_bag $self->find_unused_subs_for( fixture_simple('c'), '--no-pack' ), [ map { 'main::' . $_ } 'e' .. 'g' ], 'call c';
    cmp_bag $self->find_unused_subs_for( fixture_simple('d'), '--no-pack' ), [ map { 'main::' . $_ } 'a' .. 'c', 'e' .. 'g' ], 'call d';

    return;
}

sub test_package : Tests(1) {
    my $self = shift;

    my $subs = $self->find_unused_subs_for( fixture_package(), '--no-pack' );
    cmp_bag $subs, [ 'Bar::b2', 'Bar::b3', 'Foo::f2', 'Foo::f3' ] or note explain $subs;

    return;
}

sub test_mock : Tests(3) {
    my $self = shift;

    cmp_deeply $self->find_unused_subs_for( fixture_mock_1(), '--no-pack' ), [], 'all subs are used: mock 1';
    cmp_deeply $self->find_unused_subs_for( fixture_mock_2(), '--no-pack' ), [], 'all subs are used: mock 2';
    cmp_deeply $self->find_unused_subs_for( fixture_mock_3(), '--no-pack' ), [], 'all subs are used: mock 3';

    return;
}

sub test_scalar : Tests(1) {
    my $self = shift;

    my $subs = $self->find_unused_subs_for( fixture_scalar(), '--no-pack' );
    cmp_bag $subs, [ 'Foo::x', 'Foo::y' ] or note explain $subs;

    return;
}

# ----- helpers

sub find_unused_subs_for {
    my ( $self, $script, @opts ) = @_;

    my $f = $self->{'tmp'}->filename;
    File::Slurp::write_file( $f, $script ) or die $!;

    my $out = run_find_unused_subs( $f, @opts );
    return unless defined $out;

    my @lines = split( /\n/, $out );
    my $useless;
    my @subs;
    foreach my $l (@lines) {
        if ( $l =~ qr{^\Q*List of useless functions:\E} ) {
            $useless = 1;
            next;
        }
        next unless $useless;
        push @subs, $l if length($l);
    }

    return \@subs;
}

sub run_find_unused_subs {
    my ( $script, @opts ) = @_;

    my @cmd = ( $^X, FIND_UNUSED_SUBS, $script, @opts );
    return qx{@cmd};
}

sub fixture_simple {
    my $call = shift || 'c';

    my $s = <<'EOS';
sub a {}
sub b { a() }
sub c { b() + d() }
sub d {}
sub e { f() }
sub f {}
sub g { e() }

~CALL~();

EOS

    $s =~ s{~CALL~}{$call}g;

    return $s;
}

sub fixture_package {
    my $call = shift || 'c';

    my $s = <<'EOS';
package Foo;

sub f1 {}
sub f2 { f1() }
sub f3 { f1() }

package Bar;

sub b1 { Foo:f2() }
sub b2 { b3) }
sub b3 {}

package main;

Bar::b1();

EOS

    $s =~ s{~CALL~}{$call}g;

    return $s;
}

sub fixture_scalar {
    return <<'EOS';
package Foo;

our $Foo;

sub x  { }
sub y  { }

package Bar;

my $x = $Foo::Foo;
sub x ( $x )

package main;
Bar::x();

EOS

}

sub fixture_mock_1 {
    return <<'EOS';
package Foo;

sub xx  { }

package Bar;

*abc = *Foo::xx;
sub my { abc() }

package main;

Bar::my();
EOS
}

sub fixture_mock_2 {
    return <<'EOS';
package Foo;

sub xx  { }

package Bar;

*abc = \&Foo::xx;
sub my { abc() }

package main;

Bar::my();
EOS
}

sub fixture_mock_3 {
    return <<'EOS';
package Foo;

sub xx  { }

package Bar;

sub abc {
	goto \&Foo::xx;
}

sub my { abc() }

package main;

Bar::my();
EOS
}
