package GPG;

# GPG abstraction layer for encrypt/decrypt password database

sub new {
	my $class = shift;

    my $self  = {
    };
    
    bless $self, $class;
    return $self;
}

1;