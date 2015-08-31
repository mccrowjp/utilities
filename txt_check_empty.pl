#!/usr/bin/env perl
use strict;

my @emptyfiles;
my $filecount=0;

foreach my $file (@ARGV) {
    open(IN, $file) or die "Unable to open file $file\n";
    $filecount++;
    my $chr_first;
    read(IN, $chr_first, 1);
    close(IN);
    
    unless(length($chr_first) > 0) {
        push(@emptyfiles, $file);
    }
}

print "Total files (".$filecount.") empty: ".scalar(@emptyfiles)."\n";
foreach my $f (@emptyfiles) {
    print $f."\n";
}
