#!/gsc/bin/perl
my $REPO_FILE_PATH = "/dev/shm/genome_testing/perl_modules";
my %desired = ();

open(my $desired_fh, '<', 'desired_hashes.txt');

while (<$desired_fh>) {
    $desired{$_} = defined;
}

my $output = `cd $REPO_FILE_PATH; git ls-tree -r --full-name $ENV{'GIT_COMMIT'}`;

my @lines = split /\n/, $output;


my ($hash, $file);
foreach my $line (@lines) {
    $line =~ /\d+\sblob\s(\S+)\s(\S+)/;
    $hash = $1;
    $file = $2;
    `cd $REPO_FILE_PATH; git rm -f --cached $file` unless ( defined $desired{$hash} );
}
