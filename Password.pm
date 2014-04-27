package Password;

use strict;
use warnings;
use utf8;

use Database;

sub new {
	my $class = shift;

    my $self  = {
    	_home => $home,
    };
    
    bless $self, $class;
    return $self;
}

1;
