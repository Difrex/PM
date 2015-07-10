package Password;

use strict;
use warnings;
use utf8;

use Database;
use GPG;

use Digest::MD5;
use MIME::Base64;

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
    my ( $self, $name, $username, $g ) = @_;
    my $db_class = $self->{_db};
    my $gpg      = $self->{_gpg};

    # Decrypt db
    my $dec_db_file = $gpg->decrypt_db();

    # Query
    my $query_string;
    if ( defined($username) and !($g)) {
        $query_string = "select id, name, resource, password from passwords 
            where name='$name' and username='$username'";
    }
    # Fasthack
    elsif ( defined($g)) {
        $query_string = "select id, name, `group`, resource, username, comment from passwords where `group`='$g'";
    }
    else {
        $query_string
            = "select id, name, resource, password from passwords where name='$name'";
    }

    my $mdo_q;

    $mdo_q = {
        file  => $dec_db_file,
        query => $query_string,
        name  => $name,
        type  => 'select',
    };
    $mdo_q = {
        file  => $dec_db_file,
        query => $query_string,
        name  => $name,
        type  => 'select',
        group => $g,
    } if $g;
    my $q_hash = $db_class->mdo($mdo_q);

    # Remove unencrypted file
    my @rm_cmd = ( "rm", "-f", "$dec_db_file" );
    system(@rm_cmd) == 0 or die "Cannot remove unencrypted database! $!\n";

    return $q_hash;
}

# Remove password
sub remove {
    my ( $self, $store ) = @_;
    my $db_class = $self->{_db};
    my $gpg      = $self->{_gpg};
    my $id       = $store->{id};

    # Decrypt database
    my $dec_db_file = $gpg->decrypt_db();
    my $q           = "delete from passwords where id=$id";
    my $mdo_q       = {
        file  => $dec_db_file,
        query => $q,
        type  => 'do',
    };

    $db_class->mdo($mdo_q);
    $gpg->encrypt_db($dec_db_file);

    return 0;
}

sub export {
    my ( $self, $filename ) = @_;
    my $gpg = $self->{_gpg};

    my $dec_db_file = $gpg->decrypt_db();
    my $export_enc  = $gpg->export($dec_db_file);

    my @mv_cmd = ( 'mv', "$export_enc", "$filename" );
    system(@mv_cmd) == 0 or die "Cannot move $export_enc to $filename: $!\n";

    return 0;
}

# Decrypt base and store new password
sub save {
    my ( $self, $store ) = @_;
    my $db_class = $self->{_db};
    my $gpg      = $self->{_gpg};

    my $name     = $store->{name};
    my $resource = $store->{resource};
    my $password = $store->{password};
    my $group    = $store->{group};

    # Comment check
    my $comment = '';
    if ( defined( $store->{comment} ) ) {
        $comment = $store->{comment};
    }

    # Username check
    my $username = '';
    if ( defined( $store->{username} ) ) {
        $username = $store->{username};
    }

    # Decrypt database
    my $dec_db_file = $gpg->decrypt_db();
    my $q
        = "insert into passwords(name, resource, password, username, comment, 'group') 
            values('$name', '$resource', '$password', '$username', '$comment', '$group')";
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
    my $value;
    
    # Defaults
    my $length = 16;

    my $digest;
    for (1..32) {
        open my $rnd, "<", "/dev/urandom";
        read $rnd, $value, 1000;
        my $c = unpack( "H*", $value );
        close $rnd;

        # MORE ENTROPY
        my $ctx = Digest::MD5->new();
        $ctx->add($c);
        
        # MORE
        my $encoded = encode_base64( $ctx->hexdigest() );
        $encoded =~ s/=//g;
        $encoded =~ s/\n//g;

        $digest .= $encoded;
    }

    my @chars = split( //, $digest );
    
    my @r_special = ( '!', '@', '(', ')', '#', '$', '%', '^', '&' ); 
    for (1..10) {
        foreach my $special (@r_special) {
            $chars[ rand(@chars) ] = $special;
        }
    }

    my $string;
    $string .= $chars[ rand @chars ] for 1 .. $length;

    return $string;
}

# Check configuration. If it doesn't exist create it.
sub check_config {
    my ($self) = @_;
    if ( -e $ENV{HOME} . "/.PM/db.sqlite" ) {
        return 1;
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
