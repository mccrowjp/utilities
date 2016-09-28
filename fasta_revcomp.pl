#!/usr/bin/env perl
use strict;

sub revcomp {
    my $seq = shift;
    if(length($seq) > 0) {
        $seq =~ s/ //g;
        $seq =~ tr/acgtACGT/tgcaTGCA/;
        print reverse($seq)."\n";
    }
}

###

my $fafile = shift;

unless($fafile) {
    die "Usage: $0 [nucleotide FASTA]\n  output: reverse-complement FASTA\n";
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
        revcomp($seq);
        print $_."\n";
        $seq = "";
    } else {
        $seq .= $_;
    }
}
revcomp($seq);

close(IN);
