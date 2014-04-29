package Database;

use DBI;
use GPG;

sub new {
    my $class = shift;

    # Get home dir
    my $home = $ENV{HOME};

    my $gpg = GPG->new($home);

    my $self = {
        _home => $home,
        _gpg  => $gpg,
    };

    bless $self, $class;
    return $self;
}

sub connect {
    my ( $self, $db_file ) = @_;
    my $dbh = DBI->connect( "dbi:SQLite:dbname=$db_file", "", "" );

    return $dbh;
}

# Query proccessing mechanism
sub mdo {
    my ( $self, $query ) = @_;
    my $db_file = $query->{file};
    my $q       = $query->{query};
    my $name    = $query->{name};
    my $type    = $query->{type};

    my $dbh = Database->connect($db_file);

    # Select
    if ( $type eq 'select' ) {
        my $sth = $dbh->prepare($q);
        $sth->execute();
        my ( $name, $resource, $password ) = $sth->fetchrow_array();

        my $q_hash = {
            name     => $name,
            resource => $resource,
            password => $password,
        };
        return $q_hash;
    }
    elsif ( $type eq 'do' ) {
        $dbh->do($q) or die "$!\n";
        return 0;
    }
    else {
        print STDERR "Something went wrong! $!\n";
        return 1;
    }
    return 1;
}

# Create config dirrectory and DB if not exist
sub create_base {
    my ($self) = @_;
    my $home   = $self->{_home};
    my $pm_dir = $home . "/.PM/";
    my $gpg    = $self->{_gpg};

    # Check dir
    if ( !( -d $pm_dir ) ) {

        # Create dirrectory
        my @mkdir_cmd = ( "mkdir", "$pm_dir" );
        system(@mkdir_cmd) == 0 or die "Cannot create dir $pm_dir: $!\n";

        my $first_sqlite = '/tmp/db.sqlite';

        # Create DB file
        my @createdb_cmd = ( "touch", "$first_sqlite" );
        system(@createdb_cmd) == 0 or die "Cannot create database file: $!\n";

        # Create table.
        my $dbh = DBI->connect( "dbi:SQLite:dbname=$first_sqlite", "", "" );
        print "Create database schema\n";
        my $q_table
            = "create table passwords(name VARCHAR(32), resource TEXT, password TEXT)";
        $dbh->do($q_table);

        # Encrypt db
        $gpg->encrypt_db($first_sqlite);

        return 0;
    }
    else {
        print "Dirrectory is exist!\n";
        return 0;
    }
}

1;
