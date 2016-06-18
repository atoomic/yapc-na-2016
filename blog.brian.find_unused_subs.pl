#!/usr/bin/perl
use v5.14;
use strict;
use warnings;

use PPI;
use Scalar::Util qw(blessed);


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Create the PPI document, and add an isa method that takes a list
sub PPI::Element::isa {
	my( $self, @classes ) = @_;
	foreach my $class ( @classes ) {
		return 1 if $self->UNIVERSAL::isa( $class );
		}
	return 0;	
	}

my $Document = PPI::Document->new( $ARGV[0] );
die "Could not create PDOM!" unless blessed $Document;

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Get all of the subroutine definitions
my @subs = 
	map { $_->name } 
	@{ $Document->find( 
		sub {
			$_[1]->isa( 'PPI::Statement::Sub' )
			}
	) };
say "All sub definitions: @subs";


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find the sub calls that use &
#	&foo
#	&foo()
#	\&foo
my @symbols = 
	map  { $_->content =~ s/\A&//r; } 
	@{ $Document->find( 
		sub {
			$_[1]->isa( 'PPI::Token::Symbol' ) &&
			$_[1]->symbol_type eq '&'
			}
		) || [] };
say "All symbols: @symbols";

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find the sub calls that use parens
#	foo()
#   foo( @args )
my @list = 
	map  { $_->literal } 
	@{ $Document->find( 
		sub {
			$_[1]->isa( 'PPI::Token::Word' ) &&
			$_[1]->snext_sibling->isa( 'PPI::Structure::List' )
			}
		) || [] };
say "All list: @list";

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# find the sub calls that are barewords
#	foo
#	foo + bar
# but not
#	use vars qw( baz );
#	sub quux { ... }
my %reserved = map { $_, $_ } qw( use vars sub my );
my @barewords = 
	map  { $_->literal }
	grep {
		# Take out the Words that are preceded by 'sub'
		# That is, take out the subroutine definitions
		# I couldn't get this to work inside the find()
		my $previous  = $_->previous_sibling;
		my $sprevious = $_->sprevious_sibling;

		! (
		blessed( $previous ) &&
		blessed( $sprevious ) &&
		$previous->isa(  'PPI::Token::Whitespace' ) &&
			$sprevious->isa( 'PPI::Token::Word' ) &&
			$sprevious->literal eq 'sub'
		)
				
		}
	@{ $Document->find( 
		sub {
			$_[1]->isa( 'PPI::Token::Word' ) 
				&&
			$_[1]->next_sibling->isa( qw( 
				PPI::Token::Whitespace
				PPI::Token::Structure
				PPI::Token::List
				PPI::Token::Operator
				) ) 
				&&
			( ! exists $reserved{ $_[1]->literal } )
			}
	) || [] };
say "All barewords: @barewords";


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Combined the used subs
my %used = map { $_ => 1 } ( @symbols, @list, @barewords );
say "All used: @{ [keys %used] }";


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# The unused have to be the left over ones
my @unused = grep { ! exists $used{$_} } @subs;
say "All unused: @unused";