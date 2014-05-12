package Database;

use DBI;
use GPG;

use Password;

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

        # Bad hack
        if ( $name eq 'all' ) {
            my $q
                = 'select id, name, resource, username, comment from passwords';

            my $sth = $dbh->prepare($q);
            my $rv  = $sth->execute();

            use Term::ANSIColor;
            printf "%-11s %-11s %-11s %-11s %-11s\n",
                colored( "ID",       'white' ),
                colored( "NAME",     'magenta' ),
                colored( "RESOURCE", 'blue' ),
                colored( "USERNAME", 'green' ),
                colored( "COMMENT",  'yellow' );
            print "=================================\n";
            while ( my ( $id, $name, $resource, $username, $comment )
                = $sth->fetchrow_array() )
            {
                if ( !defined($comment) ) {
                    $comment = '';
                }
                printf "%-11s %-11s %-11s %-11s %-11s\n",
                    colored( $id,       'white' ),
                    colored( $name,     'magenta' ),
                    colored( $resource, 'blue' ),
                    colored( $username, 'green' ),
                    colored( $comment,  'yellow' );
            }

            # Remove unencrypted file
            my @rm_cmd = ( "rm", "-f", "$db_file" );
            system(@rm_cmd) == 0
                or die "Cannot remove unencrypted database! $!\n";
            exit 0;
        }

        my $sth = $dbh->prepare($q);
        $sth->execute();

        my ( $id, $name, $resource, $password ) = $sth->fetchrow_array();

        my $q_hash = {
            id       => $id,
            name     => $name,
            resource => $resource,
            password => $password,
        };
        return $q_hash;
    }
    elsif ( $type eq 'do' ) {
        $dbh->do("$q") or die "$!\n";
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
    if ( !( -d $pm_dir ) or !( -e $pm_dir . "db.sqlite" ) ) {

        # Remove old configuration dirrectory
        print "Remove old dirrectory...\n";
        my @rm_old_cmd = ( 'rm', '-rf', $pm_dir );
        system(@rm_old_cmd) == 0 or die "Cannot remove $pm_dir: $!\n";

        # Create dirrectory
        print "Creating configuration dirrectory...\n";
        my @mkdir_cmd = ( "mkdir", "$pm_dir" );
        system(@mkdir_cmd) == 0 or die "Cannot create dir $pm_dir: $!\n";

        my $pass         = Password->new();
        my $string       = $pass->generate();
        my $first_sqlite = "/tmp/$string";

        # Create DB file
        my @createdb_cmd = ( "touch", "$first_sqlite" );
        system(@createdb_cmd) == 0 or die "Cannot create database file: $!\n";

        print "Creating database...\n";

        # Create table.
        my $dbh = DBI->connect( "dbi:SQLite:dbname=$first_sqlite", "", "" );
        print "Create database schema\n";
        my $q_table
            = "create table passwords(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR(32), username VARCHAR(32),
            resource TEXT, password TEXT, comment TEXT)";
        $dbh->do($q_table);

        print "Encrypt database...\n";

        # Encrypt db
        $gpg->encrypt_db($first_sqlite);

        return 0;
    }
    else {
        print "Dirrectory is exist!\n";
        return 1;
    }
    return 1;
}

1;
