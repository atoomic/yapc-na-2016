#!/bin/perl

package MultiplePackages::Foo;

use strict;
use warnings;

sub hello { print "hello from ".__PACKAGE__."\n" }

package MultiplePackages::Bar;

use strict;
use warnings;

sub hello { print "hello from ".__PACKAGE__."\n" }


1;