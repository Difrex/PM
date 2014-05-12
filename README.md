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

# Usage

First you need to generate PGP key:

        gpg --gen-key

Set this key(or another of cource) for default:
        
        vim ~/.gnupg/gpg.conf
        # find string and uncomment or add it
        default-key key_email@example.com
        :wq

You can use not default key:

	# Create file with key email
	cat > ~/.PM/.key << EOF
	key_email@example.com
	EOF

First run:
       
        $ ./pm.pl
        Creating configuration dirrectory...
        Creating database...
        Creating database schema...
        Encrypt database...
        Done!

Show help screen:

        $ ./pm.pl -h

# Changelog

## 0.0.1-beta1

* Show all enteries
* Username support

## 0.0.1-alpha

* Small fix in GPG.pm
* PM is working.

# TODO

* Import/Export with simple(only password) encryption
* Password lenght
* Store decrypted DB into RAM not in /tmp/
