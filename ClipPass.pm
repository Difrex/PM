package ClipPass;

use Clipboard;

sub new {
    my $class = shift;

    my $self = { _password => shift, };

    bless $self, $class;
    return $self;
}

sub copy {
    my ($self) = @_;
    my $password = $self->{_password};

    if ( 'Clipboard::Xclip' eq $Clipboard::driver ) {
        no warnings 'redefine';
        *Clipboard::Xclip::all_selections = sub {
            qw(clipboard primary buffer secondary);
        };
    }

    Clipboard->copy("$password");
}

1;
