package PasswordSave;

sub new {
	my $class       = shift;
    my $self        = {
    	_name	=> shift,
    };
    bless $self, $class;
    return $self;
}

1;