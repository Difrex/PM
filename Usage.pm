package Usage;

sub new {
    my $class = shift;
    my $self  = {};

    bless $self, $class;
    return $self;
}

sub show() {
    print STDERR << "EOF";
Simple password manager writed in Perl. 

  -s                      show password
  -n [Name of resource]   name of resource
  -g [Group name]         group name
  -w                      store new password
  -l [Link]               link to resource
  -u                      username
  -c                      comment
  -p [Password]           password
                          if key not selected PM generate secure password
                          and copy it to xclipboard
  -e [number]             Password length(with length [number] if mentioned)
  -r                      remove password
  -i                      password ID
  -o                      open link
  -x [filename]           export
  -b [filename]           import database
  -h                      show this help screen and exit
  -v                      show version info and exit

Examples:

  Show all names and resources:
  \tpm.pl -s -n all

  Show all names in group:
  \tpm.pl -s -g work

  Copy password for resource:
  \tpm.pl -s -n LOR
  \tPassword copied to xclipboard.\n\t\tURI is http://linux.org.ru/

  Copy password and open link:
  \tpm.pl -s -n LOR -o
  \tPassword copied to clipboard. Trying to open uri.

  Store new password:
  \tpm.pl -w -n PRON -l http://superpronsite.com/ -p my_secret_password -c 'Most viewed site'
  \tPassword for resource PRON is stored into DB!

  Remove password:
  \tpm.pl -r -i 13
  \tPassword was removed!

EOF
    exit 1;
}

1;
