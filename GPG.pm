# GPG layer for encrypt/decrypt passwords database
package GPG;

our $gpg = '/usr/bin/gpg';

sub new {
    my $class = shift;

    my $home = shift;
    my $db   = $home . "/.PM/db.sqlite";

    # Get default private key

    my $self = { _db => $db, };

    bless $self, $class;
    return $self;
}

# Encrypt sqlite database with default key
# and save it in config dir
sub encrypt_db {
    my ( $self, $file ) = @_;
    my $db = $self->{_db};

    # gpg --output test.gpg --encrypt -a --default-recipient-self test
    @enc_cmd = (
        "$gpg", "--output",
        "$db",  "--encrypt",
        "-a",   "--default-recipient-self",
        "$file"
    );
    system(@enc_cmd) == 0 or die "Cannot encrypt! $!\n";

    # Remove unencrypted file
    @rm_cmd = ( "rm", "$file" );
    system(@rm_cmd) == 0 or die "Cannot remove file $file: $!\n";
}

# Decrypt database, save it in new place
# and return path to file
sub decrypt_db {
    my ($self) = @_;
    my $db = $self->{_db};

    # Generate random file name
    my @chars = ( "A" .. "Z", "a" .. "z" );
    my $string;
    $string .= $chars[ rand @chars ] for 1 .. 10;
    my $file = '/tmp/' . 'pm.' . $string;

    # gpg --output /tmp/decryptfile --decrypt $db
    @dec_cmd = ( "$gpg", "--decrypt", "$db", "--output", "$file" );
    system(@sys_dec_cmd) == 0 or die "Cannot decrypt $db: $!\n";

    return $file;
}

1;
