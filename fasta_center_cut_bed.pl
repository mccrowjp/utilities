#!/usr/bin/env perl
use strict;

my %cutctg;
my %cutstart;
my %cutend;
my %ctgids;
my %found;

sub eachseq {
    my ($id, $seq, $len) = @_;
    if(length($seq) > 0) {
        $seq =~ s/[^A-Za-z]//g;
        foreach my $cut (@{$ctgids{$id}}) {
            if(exists($cutstart{$cut})) {
                $found{$cut} = 1;
                my $m = int(($cutend{$cut} + $cutstart{$cut}) / 2);
                my $s;
                if($m > int($len/2)) {
                    $s = $m - int($len/2);
                } else {
                    $s = 0;
                }
                printf ">%s %s %d-%d\n%s\n", $cut, $id, $s+1, $s+$len, substr($seq, $s, $len);
            }
        }
    }
}

###

my $infile = shift;
my $bedfile = shift;
my $width = shift;

unless($infile && $bedfile && $width >= 1) {
    die "Usage: $0 [FASTA file (or .gz)] [BED file] [Cut width]\nCuts regions of specified width centered on BED file regions\n";
}

open(IN, $bedfile) or die "Unable to open file $bedfile\n";
while(<IN>) {
    chomp;
    my ($ctg, $start, $end, $id) = split(/\t/);
    if(exists($cutstart{$id})) {
        die "Duplicate ID: $id in BED file: $bedfile\n";
    }
    $cutctg{$id} = $ctg;
    $cutstart{$id} = $start;
    $cutend{$id} = $end;
    push(@{$ctgids{$ctg}}, $id);
}
close(IN);

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

my $id;
my $seq;
while(<IN>) {
    chomp;
    if(/^>/) {
        eachseq($id, $seq, $width);
        ($id) = split(/\s/, $');  #');
        $seq = "";
    } else {
        $seq .= $_;
    }
}
eachseq($id, $seq, $width);
close(IN);

if(scalar(keys %found) < scalar(keys %cutstart)) {
    print STDERR "Not all regions found: missing ".(scalar(keys %cutstart)-scalar(keys %found))."\n";
}
