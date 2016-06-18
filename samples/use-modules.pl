#!/usr/bin/env perl

use strict;
use warnings;

use v5.014;

use Carp     ();
use Config   ();
use Data::Dumper ();
use Digest   ();
use Encode   ();
use FindBin  ();

use MyPackage ();
use MultiplePackages ();

say q{Use some CORE modules};

