    package Analyze;
    use PPI;
    # similar to using Moo here, but in one line with no other deps (just need lazy builders and accessors)
    use Simple::Accessor qw{Document content subs symbols list barewords methods packages};

    sub _build_Document {
        my ($self) = @_;

        die unless ref $self->content eq 'SCALAR' or -f $self->content;

        my $Document = PPI::Document->new( $self->content );
        die "Could not create PDOM!" unless ref $Document;

        return $Document;
    }

    sub stringify {
        my $self = shift;
        return $self->Document->serialize;
    }

    # PPI::Token::Comment

    sub remove_pods     { $_[0]->remove_tokens('PPI::Token::Pod') }
    sub remove_comments { $_[0]->remove_tokens('PPI::Token::Comment') }

    sub remove_tokens {
        my ( $self, $token ) = @_;
        my $pods = $self->Document->find($token) || [];
        foreach my $pod (@$pods) {
            $pod->delete;
        }

        return;
    }

    package main;
    use v5.014;
    use File::Slurp qw{read_file write_file};

    exit run(@ARGV) unless caller;

    sub run {
        my $script = shift or die "Missing argument script name to analyze";
        
        my $content = read_file($script) or die;
        my $analyze = Analyze->new( content => \$content );

        $analyze->remove_pods();
        $analyze->remove_comments();

        my $updated = "$script.updated";
        write_file( $updated, $analyze->stringify );
        say "Write updated version to '$updated";

        return 0;
    }