#!/usr/bin/perl

use Password;

use Getopt::Std;
# Global
use vars qw / %opt /;
our $VERSION = '0.0.0a';

sub usage() {
	print STDERR << "EOF";
Simple password manager writed in Perl. 

Usage:

	-s [Name of resource]   -- Show password for resource
	-w                      -- Store new password(interactive)
	-W [Name|Link|password] -- Non interactive
	-r [Name]               -- Remove password
	-h                      -- Show this help screen and exit
	-v                      -- Show version info and exit

EOF
	exit 1;
}

sub init() {
	my $opt_string = 'swWrhv';
	# TODO: switch's to Getopt::Mixed
	getopts("$opt_string", \%opt) or usage();
	print STDOUT "Simple password manager writed in Perl.\nVersion: ".$VERSION . "\n" and exit 0 if $opt{v};
	usage if $opt{h};
}

init();
