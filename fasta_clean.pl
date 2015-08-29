#!/usr/bin/env perl
use strict;

my $seq = "";
my $seqnum = 0;

sub eachseq {
    if(length($seq) > 0) {
        $seq =~ s/[\s\t\r\n]//g;
        print $seq."\n";
    }
}

###

my $infile = shift;

unless($infile) {
    die "Usage: $0 [fasta file (or .gz)]\n";
}

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

while(<IN>) {
    chomp;
    if(/^>/) {
        eachseq();
        $seq = "";
        $seqnum++;
        print ">".$seqnum."\n";
    } else {
        $seq .= $_;
    }
}
eachseq();

close(IN);
