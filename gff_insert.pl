#!/usr/bin/env perl
use strict;

my $infile = shift;
my $cutstr1 = shift;
my $cutstr2 = shift;

my $id1;
my $start1;
my $end1;
my $id2;
my $start2;
my $end2;

unless($infile && $cutstr1 && $cutstr2) {
    die "Usage: $0 [Target GFF file] [Target cut id:start-end] [Insert cut id:start-end]\n  Inserts after target start, and appends from target end on (end > start, first position = 1)\n";
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

# Set offset based on insert length minus target deletion length
my $offset = ($end2 - $start2 + 1) - ($end1 - $start1 - 1);


if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

while(<IN>) {
    chomp;
    if(/^\#/) {
        print $_."\n";
    
    } else {
        my ($chr, $source, $feat, $s, $e, $score, $strand, $frame, $attrstr) = split(/\t/);
        if($chr eq $id1 && $s > $start1) {
            $s += $offset;
        }
        if($chr eq $id1 && $e > $start1) {
            $e += $offset;
        }
        print join("\t", ($chr, $source, $feat, $s, $e, $score, $strand, $frame, $attrstr))."\n";
    }
}

# Append new inserted ID
print join("\t", ($id1, 'gff_insert', 'CDS', $start1+1, $start1+($end2 - $start2 + 1), '.', '+', 0, 'ID='.$id2))."\n";
