#!/usr/bin/env perl
use strict;

my $infa = shift;

unless($infa) {
    die "Usage: $0 [FASTA file]\n";
}

open(IN, $infa) or die "Unable to open file $infa\n";
while(<IN>) {
    chomp;
    if(/^>([^\s]+)\s/) {
        print ">".$1."\n";
    } else {
        print $_."\n";
    }
}
close(IN);
