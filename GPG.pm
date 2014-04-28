# GPG layer for encrypt/decrypt passwords database
package GPG;

our $gpg = '/usr/bin/gpg';

sub new {
    my $class = shift;

    my $home = shift;
    my $db   = $home . "/.PM/db.sqlite";

    my $self = { _db => $db, };

    bless $self, $class;
    return $self;
}

# Encrypt sqlite database with default key
# and save it in config dir
sub encrypt_db {
    my ( $self, $file ) = @_;
    my $db = $self->{_db};

    # Remove old database
    @rm_db = ( "rm", "-f", "$db" );
    system(@rm_db) == 0 or die "Cannot remove old database: $!\n";

    # gpg --output test.gpg --encrypt -a --default-recipient-self test
    @enc_cmd = (
        "$gpg", "--output",
        "$db",  "--encrypt",
        "-a",   "--default-recipient-self",
        "$file"
    );
    system(@enc_cmd) == 0
        or die "Cannot encrypt!\nDecrypted file: $file\nTraceback: $!\n";

    # Remove unencrypted file
    @rm_cmd = ( "rm", "-f", "$file" );
    system(@rm_cmd) == 0 or die "Cannot remove file $file: $!\n";

    return 0;
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
