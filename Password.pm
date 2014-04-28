package Password;

use strict;
use warnings;
use utf8;

use Database;

use PasswordSave;
use PasswordShow;

sub new {
    my $class = shift;

    my $db = Database->new();

    my $p_save = PasswordSave->new();
    my $p_show = PasswordShow->new();

    my $self = {
        _db     => $db,
        _p_save => $p_save,
        _p_show => $p_show,
    };

    bless $self, $class;
    return $self;
}

# Check configuration. If it doesn't exist create it.
sub check_config {
    my ($self) = @_;
    if ( -e $ENV->{HOME} . "/.PM/db.sqlite" ) {
        return 0;
    }
    else {
        my $db = $self->{_db};
        $db->create_base();
    }
    return 0;
}

1;
