#!/usr/bin/env perl
use strict;

sub runcmd {
    my $run = join(" ", @_);
    print STDERR $run."\n";
    system($run);
}

###

my $sampfile = shift;
my %srrname;

unless($sampfile) {
    die "Usage: $0 [sample list file]\n  Tab delimited list of SRR number, and sample name\n";
}

open(IN, $sampfile) or die "Unable to open file $sampfile\n";
while(<IN>) {
    chomp;
    my ($srr, $name) = split(/\t/);
    $srrname{$srr} = $name;
}
close(IN);

foreach my $srr (sort keys %srrname) {
    print STDERR $srr." -> ".$srrname{$srr}."\n";
    my $srrfile1 = $srr."_1.fastq";
    my $srrfile2 = $srr."_2.fastq";
    my $newfile1 = $srrname{$srr}."_R1.fastq";
    my $newfile2 = $srrname{$srr}."_R2.fastq";

    if(-e $srrfile1 && -e $srrfile2) {
        print STDERR "skipping download: $srr\n";
    } else {
        runcmd("fastq-dump --split-files", $srr);
    }
    
    if(-e $srrfile1) {
        runcmd("mv", $srrfile1, $newfile1);
        runcmd("gzip", $newfile1);
    }
    if(-e $srrfile2) {
        runcmd("mv", $srrfile2, $newfile2);
        runcmd("gzip", $newfile2);
    }
}
