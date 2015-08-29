#!/usr/bin/env perl
use strict;

my $seq;
my %seqstr;
my $numseqs;
my $lenseq;

my $infa = shift;

unless($infa) {
    die "Usage: $0 [FASTA alignment]\n";
}

my $idnum = 0;
open(IN, $infa) or die "Unable to open file $infa\n";
while(<IN>) {
    chomp;
    if(/^>/) {
        my ($head) = split(/\s/,$');  #');
        $idnum++;
        $seq = substr("xxxxxxxxxx".$idnum, -10);
        print STDERR $seq."\t".$head."\n";
    } else {
        $seqstr{$seq} .= $_;
    }
}
close(IN);

$numseqs = scalar(keys %seqstr);
$lenseq = length($seqstr{(keys %seqstr)[1]});

print "$numseqs $lenseq\n";
foreach $seq (keys %seqstr) {
    printf "%s %s\n", $seq, $seqstr{$seq};
}
