#!/usr/bin/env perl

use strict;
use warnings;

use v5.022;

use FindBin;

say q{# @INC:};
map { say $_ } @INC;

say '';
say q{# %INC:};
map { say $_, ' => ', $INC{$_} } sort keys %INC;

1;