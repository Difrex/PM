package ClipPass;

use Clipboard;

sub new {
    my $class = shift;

    my $self = {};

    bless $self, $class;
    return $self;
}

sub copy {
    my ( $self, $password ) = @_;

    if ( 'Clipboard::Xclip' eq $Clipboard::driver ) {
        no warnings 'redefine';
        *Clipboard::Xclip::all_selections = sub {
            qw(clipboard primary buffer secondary);
        };
    }

    Clipboard->copy("$password");
}

1;
