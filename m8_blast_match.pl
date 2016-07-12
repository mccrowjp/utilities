#!/usr/bin/env perl
use strict;

my $infile = shift;

unless($infile) {
    die "Usage: $0 [Blast m8 file]\n  output: best 1-to-1 matching\n";
}

my %lnqid;
my %lnsid;
my %lnbs;
my %lne;
my %bestqidsid;
my %bestsidqid;

my $ln = 0;
open(IN, $infile) or die "Unable to open file $infile\n";
while(<IN>) {
    chomp;
    my ($qid, $sid, $pid, $len, $mm, $go, $qs, $qe, $ss, $se, $e, $bs) = split(/\t/);
    $ln++;
    $lnqid{$ln} = $qid;
    $lnsid{$ln} = $sid;
    $lnbs{$ln} = $bs;
    $lne{$ln} = $e;
}
close(IN);

foreach my $ln (sort {$lnbs{$b}<=>$lnbs{$a} || $lne{$a}<=>$lne{$b}} keys %lnqid) {
    unless(exists($bestqidsid{$lnqid{$ln}}) || exists($bestsidqid{$lnsid{$ln}})) {
	$bestqidsid{$lnqid{$ln}} = $lnsid{$ln};
	$bestsidqid{$lnsid{$ln}} = $lnqid{$ln};
    }
}

foreach my $id (sort keys %bestqidsid) {
    print $id."\t".$bestqidsid{$id}."\n";
}
