#!/usr/bin/perl

use Getopt::Std;
use Term::ANSIColor;

use Password;
use ClipPass;
use Usage;

# Debug
use Data::Dumper;

our $VERSION = '0.0.1-beta1';

my $usage = Usage->new();

sub init() {
    my $opt_string = 'swn:l:p:rhvou:i:c:x:';
    getopts("$opt_string") or $usage->show();
    our (
        $opt_s, $opt_w, $opt_n, $opt_r, $opt_l, $opt_p, $opt_h,
        $opt_v, $opt_o, $opt_u, $opt_i, $opt_c, $opt_x,
    );

    print "Simple password manager writed in Perl.\nVersion: "
        . $VERSION
        . "\n" and exit 0
        if $opt_v;
    $usage->show() if $opt_h;
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

    if ( defined( $ENV{'DISPLAY'} ) ) {
        $copy->copy($get_pass);

        print colored("Password copied to xclipboard.", 'green');
        print "\nURI is ";
        print colored($get_h->{resource} . "\n", 'bold blue');
    }
    else {
        print colored("Warning! Password will show to terminal!", 'red');
        print " Yes/No: ";
        my $ans = <STDIN>;
        chomp($ans);
        print "$get_pass\n" if $ans eq "Yes";
        print "Cancel\n" if $ans ne "Yes";
    }
}
elsif ( defined($opt_s) and defined($opt_n) and defined($opt_o) ) {

    my $get_h = $pass->show( $opt_n, $opt_u );
    $copy->copy( $get_h->{password} );

    # Open resource.
    my @open_cmd = ( 'xdg-open', $get_h->{resource} );
    system(@open_cmd) == 0 or die "Cannot open URI: $!\n";

    print colored("Password copied to clipboard.\n", 'bold green');
    print "Trying to open ";
    print colored($get_h->{resource} . "\n", 'bold blue');
}

# Remove string from db
elsif ( defined($opt_r) and defined($opt_i) ) {

    my $store_h = { id => $opt_i, };

    $pass->remove($store_h) == 0 or die "Oops! 111: pm.pl. $!\n";
    print colored("Password was removed!\n", 'bold red');
}
elsif ( defined($opt_w)
    and defined($opt_n)
    and defined($opt_l)
    and !defined($opt_p) )
{
    # Generate password and store it into DB
    print "$opt_w, $opt_n, $opt_l, $opt_p\n";

    $opt_p = $pass->generate();

    my $store_h = {
        name     => $opt_n,
        resource => $opt_l,
        password => $opt_p,
        username => $opt_u,
        comment  => $opt_c,
    };

    $pass->save($store_h) == 0 or die "Oops! 105: pm.pl. $!\n";
    $copy->copy($opt_p);
    print colored("Password was stored into DB!\n", 'green');
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
        comment  => $opt_c,
    };

    $pass->save($store_h) == 0 or die "Oops! 122: pm.pl. $!\n";
    print colored("Password was stored into DB!\n", 'green');
}
# Export
elsif ( defined($opt_x) ) {
    $pass->export($opt_x);
    print colored("Dabase stored in $opt_x\n", 'green');
}
else {
    $usage->show();
}
