#!/gsc/bin/perl

my $REPO_FILE_PATH = "/dev/shm/genome_testing/perl_modules";

my $output = `cd $REPO_FILE_PATH; git ls-tree -r --full-name HEAD`;

my @lines = split /\n/, $output;
my %desired = (); # this will ultimately contain all the blobs we want to save.
my ($hash, $file);
foreach my $line (@lines) {
    $line =~ /\d+\sblob\s(\S+)\s(\S+)/;
    $hash = $1;
    $file = $2;
    if ($file =~ /^BAP\// or
        $file =~ /^BAP.pm/ or
        $file =~ /^Bio\// or
        $file =~ /^EGAP\// or
        $file =~ /^EGAP.pm/ or
        $file =~ /^GAP\// or
        $file =~ /^GAP.pm/ or
        $file =~ /^Genome\// or
        $file =~ /^Genome.pm/ or
        $file =~ /^MGAP\// or
        $file =~ /^MGAP.pm/ or
        $file =~ /^PAP\// or
        $file =~ /^PAP.pm/) {
          #print $hash . " " . $file . "\n";
          my $shortened_hash = substr($hash, 0, 7);
          $desired{$shortened_hash} = defined;
        }
}

my @commits = (); # we will push then shift

my $commit_log = `cd $REPO_FILE_PATH; git log --oneline`; 
chomp $commit_log;
my @commits_raw = split /\n/, $commit_log;
foreach my $commit_raw (@commits_raw) {
    $commit_raw =~ /(\S+)\s/;
    push @commits, $1;    
}

my $commit = shift @commits;

foreach my $previous_commit (@commits) {
    my $diff_output = `cd $REPO_FILE_PATH; git diff --raw $previous_commit^{tree} $commit^{tree}`;
    chomp $diff_output;
    my @changes = split /\n/, $diff_output;
    foreach my $change (@changes) {
        $change =~ /:\d+\s\d+\s(\S+)\.{3}\s+(\S+)\.{3}/;
        my $prev_h = $1; #hash in previous commit
        my $this_h = $2; # hash in commit
        if (defined $desired{$this_h}) {
            $desired{$prev_h} = defined;
        }
    }
    $commit = $previous_commit;
}

while (my ($k, $v) = each(%desired)) {
    print $k . "\n";
}
