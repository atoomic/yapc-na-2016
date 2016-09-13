#!/bin/env perl

use strict;
use warnings;

sub a {}
sub b { a() }
sub c { b() + d() }
sub d {}
sub e { f() }
sub f { print 42 }
sub g { e() }

#a();
g();
