#!/usr/bin/perl

use Password;
use Getopt::Std;

our $VERSION = '0.0.0a';

# Debug
use Data::Dumper;

sub usage() {
	print STDERR << "EOF";
Simple password manager writed in Perl. 

Usage:
	-s                      -- Show password
	-n [Name of resource]   -- Name of resource
	-w                      -- Store new password
	-l [Link]               -- Link to resource
	-p [Password]           -- Password
	-r                      -- Remove password
	-o                      -- Open link
	-h                      -- Show this help screen and exit
	-v                      -- Show version info and exit

Examples:

	Show password for resource:
	\tpm.pl -s -n LOR
	\tPassword copied to xclipboard.\n\t\tLink is http://linux.org.ru/

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
	our ($opt_s, $opt_w, $opt_n, $opt_r, 
		$opt_l, $opt_p, $opt_h, $opt_v);
	
	print "Simple password manager writed in Perl.\nVersion: ".
		$VERSION."\n" and exit 0 if $opt_v;
	usage if $opt_h;
}

# Parse cmd line
init();