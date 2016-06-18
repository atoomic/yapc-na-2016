package Devel::ProcessMemory;

CHECK {

	if ( -e q{/proc} ) { # unix
    	print int qx{grep VmRSS /proc/$$/status};
     } else { # mac os x
        print int qx{ps -o rss -p $$ | tail -1};
     }

	exit
}

1;