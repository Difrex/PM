package ClipPass;

if ("$^O" ne 'darwin') {
    use Clipboard;
}

sub new {
    my $class = shift;

    my $self = {};

    bless $self, $class;
    return $self;
}

sub copy {
    my ( $self, $password ) = @_;

    if ("$^O" eq 'linux') {
        if ( 'Clipboard::Xclip' eq $Clipboard::driver ) {
            no warnings 'redefine';
            *Clipboard::Xclip::all_selections = sub {
                qw(clipboard primary buffer secondary);
            };
    }
        Clipboard->copy("$password");
    } elsif ("$^O" eq 'darwin') {
        my $pbcopy = "echo '$password' | pbcopy";
        system($pbcopy) == 0 or die "$!\n";
    }
}

1;
