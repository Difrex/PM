#!/usr/bin/perl

use Password;
use Getopt::Std;

our $VERSION = '0.0.0d';

# Debug
use Data::Dumper;

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
    my $opt_string = 'swn:l:p:rhv';
    getopts("$opt_string") or usage();
    our ( $opt_s, $opt_w, $opt_n, $opt_r, $opt_l, $opt_p, $opt_h, $opt_v );

    print "Simple password manager writed in Perl.\nVersion: "
        . $VERSION
        . "\n" and exit 0
        if $opt_v;
    usage if $opt_h;
}

# Parse cmd line
init();

my $pass = Password->new();

# Don't use it's before GPG and Database
# $pass->check_config() == 0 or die "$!\n";
