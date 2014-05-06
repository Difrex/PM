PM
==

Simple password manager writed in perl.

# INSTALL

## Perl modules

	cpan install Module::Name

Not recommended. Please use you package manager.

* DBD::sqlite
* Clipboard

On Fedora:

	yum/dnf install perl-Class-DBI-SQLite perl-Clipboard

On Debian-based systems:

	apt-get install libtext-clip-perl class-dbi-sqlite-perl


# Changelog

## 0.0.1-alpha

* Small fix in GPG.pm
* PM is working.

# TODO

* Username support
* Store decrypted DB into RAM not in /tmp/
* Different keys selection
