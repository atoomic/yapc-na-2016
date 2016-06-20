package Devel::ListDeps;

CHECK {
	foreach my $module ( sort keys %INC ) {
		next if $module eq 'Devel/ListDeps.pm'; # ...
		print qq{$module\n};
	}
	exit;
}

1;