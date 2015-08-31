#!/usr/bin/env perl
use strict;

my $pattern = shift;
my $infa = shift;

my $read;

if($pattern && $infa) {
} else {
    die "Usage: $0 [pattern] [fasta file]\n";
}

open(IN, $infa) or die "Unable to open file $infa\n";
while(<IN>) {
    if(/^>/) {
        $read = 0;
        if(/$pattern/) {
            $read = 1;
        }
    }
    if($read) {
        print $_;
    }
}
close(IN);
