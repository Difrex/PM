#!/usr/bin/perl

use Password;
use Getopt::Std;
use ClipPass;

# Debug
use Data::Dumper;

our $VERSION = '0.0.1-beta1';

sub usage() {
    print STDERR << "EOF";
Simple password manager writed in Perl. 

  -s                      show password
  -n [Name of resource]   name of resource
  -w                      store new password
  -l [Link]               link to resource
  -u                      username
  -p [Password]           password
                          if key not selected PM generate secure password
                          and copy it to xclipboard
  -r                      remove password
  -i                      password ID
  -o                      open link
  -h                      show this help screen and exit
  -v                      show version info and exit

Examples:

  Show all names and resources:
  \tpm.pl -s -n all

  Show password for resource:
  \tpm.pl -s -n LOR
  \tPassword copied to xclipboard.\n\t\tURI is http://linux.org.ru/

  Store new password:
  \tpm.pl -w -n PRON -l http://superpronsite.com/ -p my_secret_password
  \tPassword for resource PRON is stored into DB!

  Copy password and open link:
  \tpm.pl -s -n LOR -o
  \tPassword copied to clipboard. Trying to open uri.

EOF
    exit 1;
}

sub init() {
    my $opt_string = 'swn:l:p:rhvou:i:';
    getopts("$opt_string") or usage();
    our (
        $opt_s, $opt_w, $opt_n, $opt_r, $opt_l, $opt_p,
        $opt_h, $opt_v, $opt_o, $opt_u, $opt_i,
    );

    print "Simple password manager writed in Perl.\nVersion: "
        . $VERSION
        . "\n" and exit 0
        if $opt_v;
    usage if $opt_h;
}

my $pass = Password->new();

if ( $pass->check_config() == 0 ) {
    exit 0;
}

init();

my $copy = ClipPass->new();

# Command line arguments switch
# It's really ugly code. Sorry :(
if ( defined($opt_s) and defined($opt_n) and !defined($opt_o) ) {

    my $get_h = $pass->show( $opt_n, $opt_u );
    my $get_pass = $get_h->{password};

    $copy->copy($get_pass);

    # TEST
    use Term::ANSIColor;
    print color 'green';
    print "Password copied to xclipboard.";
    print color 'reset';
    print "\nURI is ";
    print color 'bold blue';
    print $get_h->{resource} . "\n";
    print color 'reset';
}
elsif ( defined($opt_s) and defined($opt_n) and defined($opt_o) ) {

    my $get_h = $pass->show( $opt_n, $opt_u );
    $copy->copy( $get_h->{password} );

    # Open resource.
    my @open_cmd = ( 'xdg-open', $get_h->{resource} );
    system(@open_cmd) == 0 or die "Cannot open URI: $!\n";

    print "Password copied to clipboard. Trying to open uri.\n";
}
# Remove string from db
elsif ( defined($opt_r) and defined($opt_i) ) {

    my $store_h = { id => $opt_i, };

    $pass->remove($store_h) == 0 or die "Oops! 105: pm.pl. $!\n";
}
elsif ( defined($opt_w)
    and defined($opt_n)
    and defined($opt_l)
    and !defined($opt_p) )
{
    # Generate password and store it into DB
    print "$opt_w, $opt_n, $opt_l, $opt_p\n";

    my $store_h = {
        name     => $opt_n,
        resource => $opt_l,
        gen      => 1,
        username => $opt_u,
    };

    $pass->save($store_h) == 0 or die "Oops! 105: pm.pl. $!\n";
}
elsif ( defined($opt_w)
    and defined($opt_n)
    and defined($opt_l)
    and defined($opt_p) )
{
    # Store new password into DB
    print "$opt_w, $opt_n, $opt_l, $opt_p\n";

    my $store_h = {
        name     => $opt_n,
        resource => $opt_l,
        password => $opt_p,
        gen      => 0,
        username => $opt_u,
    };

    $pass->save($store_h) == 0 or die "Oops! 122: pm.pl. $!\n";
}
else {
    usage;
}
