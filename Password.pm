package Password;

use strict;
use warnings;
use utf8;

use Database;
use GPG;

use PasswordSave;
use PasswordShow;

sub new {
    my $class = shift;

    my $db  = Database->new();
    my $gpg = GPG->new( $ENV{HOME} );

    my $p_save = PasswordSave->new();
    my $p_show = PasswordShow->new();

    my $self = {
        _db     => $db,
        _gpg    => $gpg,
        _p_save => $p_save,
        _p_show => $p_show,
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

# Check configuration. If it doesn't exist create it.
sub check_config {
    my ($self) = @_;
    if ( -e $ENV{HOME} . "/.PM/db.sqlite" ) {
        return 0;
    }
    else {
        my $db = $self->{_db};
        $db->create_base();
    }
    return 0;
}

1;
