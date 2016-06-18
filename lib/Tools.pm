package Tools;

use Data::Dumper ();
use Encode       ();
use Digest       ();

sub dump {
	return Data::Dumper::Dumper( @_ );
}

sub encode {
	my $characters = shift;
	return Encode::encode('UTF-8', $characters, Encode::FB_CROAK);
}

sub decode {
	my $octets = shift;
	return Encode::decode('UTF-8', $octets,     Encode::FB_CROAK);
}

sub digest {
	my $md5  = Digest->new("MD5");
	$md5->add("this is a text");

	return $md5->hexdigest;
}

sub module_to_path {
    my $s = shift;

    $s =~ s{::}{/}g;
    $s .= '.pm';

    return $s;
}

1;