#!/usr/bin/env perl

use strict;
use warnings;

use v5.014;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Tools ();

say Tools::dump([ 1..5 ]);
say Tools::decode( Tools::encode('a text') );
say Tools::digest( 'good meal' );
say Tools::module_to_path( 'A::B::C' );

