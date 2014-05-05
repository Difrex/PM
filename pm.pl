#!/usr/bin/perl

use Password;
use Getopt::Std;
use ClipPass;

# Debug
use Data::Dumper;

our $VERSION = '0.0.1a';

sub usage() {
    print STDERR << "EOF";
Simple password manager writed in Perl. 

  -s                      show password
  -n [Name of resource]   name of resource
  -w                      store new password
  -l [Link]               link to resource
  -p [Password]           password
                          if key not selected PM generate secure password
                          and copy it to xclipboard
  -r                      remove password
  -o                      open link
  -h                      show this help screen and exit
  -v                      show version info and exit

Examples:

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
    my $opt_string = 'swn:l:p:rhvo';
    getopts("$opt_string") or usage();
    our (
        $opt_s, $opt_w, $opt_n, $opt_r, $opt_l,
        $opt_p, $opt_h, $opt_v, $opt_o
    );

    print "Simple password manager writed in Perl.\nVersion: "
        . $VERSION
        . "\n" and exit 0
        if $opt_v;
    usage if $opt_h;
}

my $pass = Password->new();

# Don't use it's before GPG and Database
# $pass->check_config() == 0 or die "$!\n";

# Parse cmd line
init();

my $copy = ClipPass->new();

# Command line arguments switch
if ( defined($opt_s) and defined($opt_n) and !defined($opt_o) ) {

    # Copy password to xclipboard
    print "$opt_s, $opt_n\n";
}
elsif ( defined($opt_s) and defined($opt_n) and defined($opt_o) ) {

    # Copy password to xclipboard and open the uri
    print "$opt_s, $opt_n, $opt_o\n";
}
elsif ( defined($opt_w)
    and defined($opt_n)
    and defined($opt_l)
    and !defined($opt_p) )
{
    # Generate password and store it into DB
    print "$opt_w, $opt_n, $opt_l, $opt_p\n";
}
elsif ( defined($opt_w)
    and defined($opt_n)
    and defined($opt_l)
    and defined($opt_p) )
{
    # Store new password into DB
    print "$opt_w, $opt_n, $opt_l, $opt_p\n";
}
else {
    print "FAIL\n" and usage;
}
