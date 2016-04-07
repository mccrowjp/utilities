#!/usr/bin/env perl
use strict;

my $infile1 = shift;
my $cutstr1 = shift;
my $infile2 = shift;
my $cutstr2 = shift;

my $id1;
my $start1;
my $end1;
my $id2;
my $start2;
my $end2;

my $target_left = "";
my $target_right = "";

###

sub cuttarget {
    my ($thisid, $thisseq) = @_;
    
    if($thisid eq $id1 && length($thisseq) > 0) {
        $target_left = substr($thisseq, 0, $start1);
        $target_right = substr($thisseq, $end1-1);
    }
}

sub cutinsert {
    my ($thisid, $thisseq) = @_;
    
    if($thisid eq $id2 && length($thisseq) > 0) {
        my $insertstr = substr($thisseq, $start2-1, $end2-$start2+1);
        printf ">%s %d-%d insert %s:%d-%d\n", $id1, $start1, $end1, $id2, $start2, $end2;
        print $target_left.$insertstr.$target_right."\n";
    }
}

###

unless($infile1 && $cutstr1 && $infile2 && $cutstr2) {
    die "Usage: $0 [Target FASTA file] [Target cut id:start-end] [Insert FASTA file] [Insert cut id:start-end]\n  Inserts after target start, and appends from target end on (end > start, first position = 1)\n";
}

if($cutstr1 =~ /^([^:]+):(\d+)-(\d+)$/) {
    $id1 = $1;
    $start1 = $2;
    $end1 = $3;
    unless($end1 > $start1) {
        die "Must set: target end >= start + 1\n";
    }
    
} else {
    die "Cut format: id:start-end\n";
}

if($cutstr2 =~ /^([^:]+):(\d+)-(\d+)$/) {
    $id2 = $1;
    $start2 = $2;
    $end2 = $3;
    unless($end2 >= $start2) {
        die "Must set: insert end >= start\n";
    }
    
} else {
    die "Cut format: id:start-end\n";
}

if($infile1 =~ /\.gz$/) {
    open(IN, "gunzip -c $infile1 2>/dev/null |");
} else {
    open(IN, $infile1) or die "Unable to open file $infile1\n";
}

my $thisid;
my $seq;

while(<IN>) {
    chomp;
    if(/^>/) {
        cuttarget($thisid, $seq);
        ($thisid) = split(/[\s\t]/, $');  #');
        $seq = "";
        
    } else {
        s/[\s\t\r\n]//g;
        $seq .= $_;
    }
}
cuttarget($thisid, $seq);

if($infile2 =~ /\.gz$/) {
    open(IN, "gunzip -c $infile2 2>/dev/null |");
} else {
    open(IN, $infile2) or die "Unable to open file $infile2\n";
}

$thisid = "";
$seq = "";

while(<IN>) {
    chomp;
    if(/^>/) {
        cutinsert($thisid, $seq);
        ($thisid) = split(/[\s\t]/, $');  #');
        $seq = "";
        
    } else {
        s/[\s\t\r\n]//g;
        $seq .= $_;
    }
}
cutinsert($thisid, $seq);
