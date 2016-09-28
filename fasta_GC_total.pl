#!/usr/bin/env perl
use strict;

my $fafile = shift;

unless($fafile) {
    die "Usage: $0 [Nucleotide FASTA]\n";
}

my $seq = "";
if($fafile =~ /\.gz$/) {
    open(IN, "gunzip -c $fafile 2>/dev/null |");
} else {
    open(IN, $fafile) or die "Unable to open file $fafile\n";
}
while(<IN>) {
    chomp;
    unless(/^>/) {
	$seq .= $_;
    }
}
close(IN);

$seq =~ s/[\s\t\r\n]//g;
my $n = length($seq);
if($n > 0) {
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
