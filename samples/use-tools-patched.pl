#!/usr/bin/env perl

use strict;
use warnings;

use v5.014;

BEGIN {
	$INC{'Carp.pm'} 		= '__FAKE__';
	$INC{'Data/Dumper.pm'} 	= '__FAKE__';
}

use FindBin;
use lib "$FindBin::Bin/../lib";
use Tools ();

map { say $_ } sort keys %INC;

#say Tools::dump([ 1..5 ]);
say Tools::decode( Tools::encode('a text') );
say Tools::digest( 'good meal' );
say Tools::module_to_path( 'A::B::C' );

