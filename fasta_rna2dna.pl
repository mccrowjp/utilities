#!/usr/bin/env perl
use strict;

sub rna2dna {
    my $seq = shift;
    
    $seq =~ s/\s//g;
    $seq =~ tr/uU/tT/;
    if(length($seq) > 0) {
        print $seq."\n";
    }
}

###

my $fafile = shift;

unless($fafile) {
    die "Usage: $0 [RNA/DNA fasta]\n  output: DNA fasta\n";
}

my $seq = "";
if($fafile =~ /\.gz$/) {
    open(IN, "gunzip -c $fafile 2>/dev/null |");
} else {
    open(IN, $fafile) or die "Unable to open file $fafile\n";
}
while(<IN>) {
    chomp;
    if(/^>/) {
        rna2dna($seq);
        print $_."\n";
        $seq = "";
    } else {
        $seq .= $_;
    }
}
rna2dna($seq);

close(IN);
