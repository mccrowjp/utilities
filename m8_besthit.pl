#!/usr/bin/env perl
use strict;

my %bestbs;
my %bestline;

my $infile = shift;
unless($infile) {
    die "Usage: $0 [Blast m8 file]\n  output: best single hit to each query sequence\n";
}

open(IN, $infile) or die "Unable to open file $infile\n";

my $lastid;
while(<IN>) {
    chomp;
    unless(/^\#/) {
	my ($qid, $sid, $pid, $len, $mm, $go, $qs, $qe, $ss, $se, $e, $bs) = split(/\t/);
	if($bs > $bestbs{$qid}) {
	    $bestbs{$qid} = $bs;
	    $bestline{$qid} = $_;
    }
}
close(IN);

foreach my $id (sort keys %bestline) {
    print $bestline{$id}."\n";
}
