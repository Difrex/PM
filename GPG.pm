# GPG layer for encrypt/decrypt passwords database
package GPG;

# Debug
use Data::Dumper;

sub new {
    my $class = shift;

    my $home = $ENV{HOME};
    my $db   = $home . "/.PM/db.sqlite";

    my $self = {
        _db   => $db,
        _home => $home,
    };

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

    # Keys selection.
    my @enc_cmd;
    my $recipient;
    if ( -e $self->{_home} . "/.PM/.key" ) {
        open my $key_f, "<", $self->{_home} . "/.PM/.key"
            or die "Cannot open file: $!\n";
        while (<$key_f>) {
            $recipient = $_;
        }
        @enc_cmd = (
            "gpg",         "--output",   "$db",       "-a",
            "--recipient", "$recipient", "--encrypt", "$file",
        );
    }
    else {
        # gpg --output test.gpg --encrypt test -a --default-recipient-self
        @enc_cmd = (
            "gpg", "--output", "$db", "-a", "--default-recipient-self",
            "--encrypt", "$file",
        );
    }

    system(@enc_cmd) == 0
        or die "Cannot encrypt!\nDecrypted file: $file\nTraceback: $!\n";

    # Remove unencrypted file
    @rm_cmd = ( "rm", "-f", "$file" );
    system(@rm_cmd) == 0 or die "Cannot remove file $file: $!\n";

    # Change file permissions
    @chmod_cmd = ( "chmod", 600, $db );
    system(@chmod_cmd) == 0 or die "Cannot chmod $file: $!\n";

    return 0;
}

# Decrypt database, save it in new place
# and return path to file
sub decrypt_db {
    my ($self) = @_;
    my $db = $self->{_db};

    my $gpg = '/usr/bin/gpg';

    # Generate random file name
    my @chars = ( "A" .. "Z", "a" .. "z" );
    my $string;
    $string .= $chars[ rand @chars ] for 1 .. 10;
    my $file = '/tmp/' . 'pm.' . $string;

    # gpg --output /tmp/decryptfile --decrypt $db
    @dec_cmd = ( "$gpg", "--output", "$file", "--decrypt", "$db" );
    system(@dec_cmd) == 0 or die "Cannot decrypt $db: $!\n";

    # Change file permissions
    @chmod_cmd = ( "chmod", 600, $file );
    system(@chmod_cmd) == 0 or die "Cannot chmod $file: $!\n";

    return $file;
}

sub export {
    my ( $self, $file ) = @_;

    use Term::ANSIColor;
    print "Password for " . colored( "export\n", 'yellow' );

    # gpg --symmetric filename
    my @enc_cmd = ( 'gpg', '--symmetric', "$file" );
    system(@enc_cmd) == 0 or die "Cannot encrypt $file: $!\n";

    # Remove unencrypted file
    my @rm_cmd = ( 'rm', '-f', "$file" );
    system(@rm_cmd) == 0 or die "Cannot remove file $file: $!\n";

    my $export_file = $file . '.gpg';

    return $export_file;
}

sub import {
    my ( $self, $file ) = @_;

    # Generate random file name
    my @chars = ( "A" .. "Z", "a" .. "z" );
    my $string;
    $string .= $chars[ rand @chars ] for 1 .. 10;
    my $dec_file = "/tmp/pm." . $string;

    # Decrypt database
    # gpg --output filepath --decrypt encfile
    my @dec_cmd = ( 'gpg', '--output', $dec_file, '--decrypt', $file );
    system(@dec_cmd) == 0 or die "Cannot decrypt file $file: $!\n";

    return $dec_file;
}

1;
