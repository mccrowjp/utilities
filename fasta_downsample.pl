#!/usr/bin/env perl
use strict;

my $fafile = shift;
my $ratio = shift;

unless($fafile && $ratio > 0 && $ratio < 1) {
    die "Usage: $0 [FASTA file] [sample ratio (0-1)]\n";
}

if($fafile =~ /\.gz$/) {
    open(IN, "gunzip -c $fafile 2>/dev/null |");
} else {
    open(IN, $fafile) or die "Unable to open file $fafile\n";
}
my $write = 0;
while(<IN>) {
    if(/^>/) {
	$write = (rand() < $ratio);
    }
    if($write) {
	print $_;
    }
}
close(IN);
