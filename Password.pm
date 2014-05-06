package Password;

use strict;
use warnings;
use utf8;

use Database;
use GPG;

# Debug
use Data::Dumper;

sub new {
    my $class = shift;

    my $db  = Database->new();
    my $gpg = GPG->new( $ENV{HOME} );

    my $self = {
        _db  => $db,
        _gpg => $gpg,
    };

    bless $self, $class;
    return $self;
}

sub show {
    my ( $self, $name ) = @_;
    my $db_class = $self->{_db};
    my $gpg      = $self->{_gpg};

    # Decrypt db
    my $dec_db_file = $gpg->decrypt_db();

    # Query
    my $query_string
        = "select name, resource, password from passwords where name='$name'";

    my $mdo_q = {
        file  => $dec_db_file,
        query => $query_string,
        name  => $name,
        type  => 'select',
    };
    my $q_hash = $db_class->mdo($mdo_q);

    # Remove unencrypted file
    my @rm_cmd = ( "rm", "-f", "$dec_db_file" );
    system(@rm_cmd) == 0 or die "Cannot remove unencrypted database! $!\n";

    return $q_hash;
}

# Decrypt base and store new password
sub save {
    my ( $self, $store ) = @_;
    my $db_class = $self->{_db};
    my $gpg      = $self->{_gpg};

    my $name     = $store->{name};
    my $resource = $store->{resource};
    my $password = $store->{password};
    my $generate = $store->{gen};
    # my $username = $store->{username};

    if ( $generate == 1 ) {
        $password = Password->generate();
    }

    # Decrypt database
    my $dec_db_file = $gpg->decrypt_db();
    my $q
        = "insert into passwords(name, resource, password) 
            values('$name', '$resource', '$password')";
    my $mdo_q = {
        file  => $dec_db_file,
        name  => $name,
        query => $q,
        type  => 'do',
    };

    $db_class->mdo($mdo_q);
    $gpg->encrypt_db($dec_db_file);

    return 0;
}

# Generate password
sub generate {
    my @chars = ( "A" .. "Z", "a" .. "z", 0 .. 9 );
    my $string;
    $string .= $chars[ rand @chars ] for 1 .. 16;

    return $string;
}

# Check configuration. If it doesn't exist create it.
sub check_config {
    my ($self) = @_;
    if ( -e $ENV{HOME} . "/.PM/db.sqlite" ) {
        return 0;
    }
    else {
        my $db = $self->{_db};
        $db->create_base();

        print "Done!\n";
        return 0;
    }
    return 1;
}

1;
