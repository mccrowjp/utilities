#!/usr/bin/env perl
use strict;

my $id;
my $seq = "";

sub printGC {
    my $n = length($seq);
    
    if($n > 0) {
        $seq =~ s/\s//g;
        my $nogc = $seq;
        my $noat = $seq;
        $nogc =~ s/[gGcC]//g;
        $noat =~ s/[aAtT]//g;
        my $gc = $n-length($nogc);
        my $at = $n-length($noat);
        
        if(length($id) > 0 && $gc+$at > 0) {
            printf "%s\t%.4f\n", $id, $gc/($gc+$at);
        }
    }
}

###

my $fafile = shift;

unless($fafile) {
    die "Usage: $0 [Nucleotide FASTA]\n";
}

open(IN, $fafile) or die "Unable to open file $fafile\n";
while(<IN>) {
    chomp;
    if(/^>/) {
        printGC();
        ($id) = split(/[\t\s\r\n]/, $');  #');
        $seq = "";
    } else {
        $seq .= $_;
    }
}
printGC();

close(IN);
