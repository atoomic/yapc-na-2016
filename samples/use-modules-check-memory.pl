#!/usr/bin/env perl

use strict;
use warnings;

use Carp     ();
use Config   ();
use Data::Dumper ();
use Digest   ();
use Encode   ();
use FindBin  ();

print qx{grep VmRSS /proc/$$/status} if -e q{/proc};