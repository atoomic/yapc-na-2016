package Devel::ListDepsDetails;


# > perl -Ilib -d:ListDepsDetails ./samples/use-modules.pl
# > perl -Ilib -d:ListDepsDetails -e 'require "./samples/use-modules.pl"'

BEGIN {
    sub get_memory {
        my $m;
        if ( -e q{/proc} ) { # unix
            $m = qx{grep VmRSS /proc/$$/status};
        } else { # mac os x (not consistent)
            $m = qx{ps -o rss -p $$ | tail -1};
        }
        return int $m;
    }

    my @inc = sort { length $b <=> length $a or $a cmp $b } @INC;
    sub short  {
        my $s = shift;

        foreach my $in ( @inc ) {
            next unless $s =~ s{^$in/?}{};
            
            if ( $s =~ qr{\.pm$} ) {
                $s =~ s{\.pm$}{};
                $s =~ s{/+}{::}g;
            }
            last;
        }

        return $s;
    }

    my %seen;
    my $total_mem = 0;
    sub DB::DB {
        my ( $package, $file, $line ) = caller;

        return if $file eq '-e' || $file eq '-E';
        return if $file =~ qr{^\(eval};

        return if $seen{$file}++;

        $file ||= '';

        my $mem   = get_memory();
        my $delta = $mem - $total_mem;
        $total_mem = $mem;
        if ( keys %seen == 1 ) {
            print "# [delta => total RSS in kB] module name (or eval)\n";
        }

        # try to guess where it comes from (manual longmess :-)
        my ( $frompkg, $fromfile, $fromline ) = caller();
        my $max = 1_000;
        foreach my $level ( 0 .. $max ) {
            my ( $package, $filename, $line ) = caller($level);
            last unless defined $filename;
            if ( $fromfile ne $filename ) {    # when the filename differs, we know where it comes from
                ( $frompkg, $fromfile, $fromline ) = ( $package, $filename, $line );
                last;
            }
            if ( $level == $max ) {
                ( $frompkg, $fromfile, $fromline ) = ( '????', '????', '?' );
            }
        }

        print sprintf( "[%5s => %8d] %-50s from %-30s at line %d\n", ( $delta > 0 ? '+' : '' ) . $delta, $mem, ( short($file) || 'undef' ), short($fromfile), $fromline );

        return;
    }

}

CHECK { exit }

1;