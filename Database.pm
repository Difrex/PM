package Database;

use DBI;

sub new {
    my $class = shift;

	# Get home dir
	my $home = $ENV{HOME};

    my $self  = {
    	_home 	=> $home;
    };

    bless $self, $class;
    return $self;
}

sub connect {
	my ($self) = @_;
	my $home 	= $self->{_home};
	my $db_file = $home . "/.PM/db.sqlite";
    
    my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","");

    return $dbh;
}

sub mdo {
	my ($self) = @_;
	my $dbh = $self->{_dbh};
}

sub create_base {
	my ($self) 	= @_;
	my $home 	= $self->{_home};
	my $pm_dir 	= $home."/.PM/";
	
	# Check dir 
	if !(-d $pm_dir) {
		# Create dirrectory
		@mkdir_cmd = ("mkdir", "$pm_dir");
		system(@mkdir_cmd) == 0 or die "Cannot create dir $pm_dir: $!\n";

		# Create DB file
		@createdb_cmd = ("touch", "$pm_dir/db.sqlite");
		system(@createdb_cmd) == 0 or die "Cannot create database file: $!\n";

		# Create table. TODO: write this
		my $dbh = DBI->connect("dbi:SQLite:dbname=$pm_dir/db.sqlite","","");
		print "Create database schema\n";
		my $q_table = "create table passwords(name VARCHAR(32), resource TEXT, password TEXT)";

		return 0;
	}
	else {
		print "Dirrectory is exist!\n";
		return 0;
	}
}

1;