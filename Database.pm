package Database;

use DBI;
use GPG;
use Term::ANSIColor;

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

sub print_table {
    my ( $sth ) = @_;

    @max = (0, 0, 0, 0, 0, 0);
    @rows;
    $sum = 2;

    @colors = ("white", "magenta", "bold magenta", "blue", "green", "yellow");
    while ( my @row = $sth->fetchrow_array() )
    {
        push(@rows, \@row);		
    }

    @labels = ("ID", "NAME", "GROUP", "RESOURCE", "USERNAME", "COMMENT");
    @rows=reverse(@rows);
    push(@rows, \@labels);

    foreach my $row(@rows) {
        for $i (0 .. 5) {
            $str = $row -> [$i];
            $l=length($str);
            if ($l > $max[$i]) {
                $max[$i] = $l;
            }
        }
    }

    foreach my $num(@max) {
        $sum += ($num + 3);
    }

    while (my $row = pop(@rows)) {
        print "-" x $sum . "\n";
        for $i (0 .. 5) {
            $l=$max[$i];
            $string=$row -> [$i];
            $strl=$l-length($string);
            $color=$colors[$i];
            printf "| %s ", colored($string, $color).(' ' x $strl);
        }
        print " |\n";
    }
    print "-" x $sum . "\n";
}

# Query proccessing mechanism
sub mdo {
    my ( $self, $query ) = @_;
    my $db_file = $query->{file};
    my $q       = $query->{query};
    my $name    = $query->{name};
    my $type    = $query->{type};
    my $g       = $query->{group};

    my $dbh = Database->connect($db_file);

    # Select
    if ( $type eq 'select' ) {

        # Bad hack
        if ( $name eq 'all' ) {
            my $q
                = 'select id, name, `group`, resource, username, comment from passwords';

            my $sth = $dbh->prepare($q);
            my $rv  = $sth->execute();

            print_table ($sth);

            # Remove unencrypted file
            my @rm_cmd = ( "rm", "-f", "$db_file" );
            system(@rm_cmd) == 0
                or die "Cannot remove unencrypted database! $!\n";
            exit 0;
        }

        # Show group
        if ($g) {
            my $sth = $dbh->prepare($q);
            my $rv  = $sth->execute();

            print_table($sth);

            # Remove unencrypted file
            my @rm_cmd = ( "rm", "-f", "$db_file" );
            system(@rm_cmd) == 0
                or die "Cannot remove unencrypted database! $!\n";
            exit 0;
        }

        my $sth = $dbh->prepare($q);
        $sth->execute();

        my ( $id, $name, $resource, $password, $username ) = $sth->fetchrow_array();

        my $q_hash = {
            id       => $id,
            name     => $name,
            resource => $resource,
            password => $password,
            username => $username
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
            = "CREATE TABLE passwords(
                    `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
                    name VARCHAR(32) NOT NULL, 
                    username VARCHAR(32) NOT NULL, 
                    resource TEXT NOT NULL, 
                    password VARCHAR(32) NOT NULL, 
                    comment TEXT NOT NULL, 
                    'group' VARCHAR(32) NOT NULL
                )";
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
