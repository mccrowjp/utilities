#!/usr/bin/env perl
use strict;

my $fafile = shift;

unless($fafile) {
    die "Usage: $0 [Nucleotide FASTA]\n";
}

my $seq = "";
open(IN, $fafile) or die "Unable to open file $fafile\n";
while(<IN>) {
    chomp;
    if(/^>/) {
        $seq .= $_;
    }
}
close(IN);

my $n = length($seq);
if($n > 0) {
    $seq =~ s/\s//g;
    my $nogc = $seq;
    my $noat = $seq;
    $nogc =~ s/[gGcC]//g;
    $noat =~ s/[aAtT]//g;
    my $gc = $n-length($nogc);
    my $at = $n-length($noat);
    
    if($gc+$at > 0) {
        printf "%.4f\n", $gc/($gc+$at);
    }
}
