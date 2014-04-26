package Password;

use strict;
use warnings;
use utf8;

use DBI;

sub new {
	my $class = shift;

	# Get home dir
	$home = $ENV{HOME};

    my $self  = {
    	_home => $home,
    };
    
    bless $self, $class;
    return $self;
}

sub create_base {
	my $self 	= shift;
	my $home 	= $self->{_home};
	my $pm_dir 	= $home."/.PM/";
	
	# Check dir 
	if !(-d $pm_dir) {
		# Create dirrectory
		@cmd_string = ("mkdir", "$pm_dir");
		system(@cmd_string) == 0 or die "Cannot create dir $pm_dir: $!\n";
		# Create database. TODO: write this
		my $dbi = DBI->connect("DBD::sqlite");
	}
	else {
		print "dirrectory is exist!\n";
		return 0;
	}
}

1;