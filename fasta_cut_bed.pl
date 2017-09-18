#!/usr/bin/env perl
use strict;

my %cutctg;
my %cutstart;
my %cutend;
my %cutstrand;
my %ctgids;
my %found;

sub eachseq {
    my ($id, $seq) = @_;
    if(length($seq) > 0) {
        $seq =~ s/[^A-Za-z]//g;
        foreach my $cut (@{$ctgids{$id}}) {
            if(exists($cutstart{$cut})) {
                $found{$cut} = 1;
                my $s = $cutstart{$cut} - 1;
                my $len = $cutend{$cut} - $cutstart{$cut} + 1;
                my $cutseq = substr($seq, $s, $len);
                if($cutstrand{$cut} eq '-') {
                    $cutseq =~ tr/ACGTacgt/TGCAtgca/;
                    $cutseq = reverse($cutseq);
                }
                printf ">%s %s %d-%d %s\n%s\n", $cut, $id, $cutstart{$cut}, $cutend{$cut}, $cutstrand{$cut}, $cutseq;
            }
        }
    }
}

###

my $infile = shift;
my $bedfile = shift;

unless($infile && $bedfile) {
    die "Usage: $0 [FASTA file (or .gz)] [BED file]\n";
}

open(IN, $bedfile) or die "Unable to open file $bedfile\n";
while(<IN>) {
    chomp;
    my ($ctg, $start, $end, $id, $score, $strand) = split(/\t/);
    if(exists($cutstart{$id})) {
        die "Duplicate ID: $id in BED file: $bedfile\n";
    }
    $cutctg{$id} = $ctg;
    $cutstart{$id} = $start;
    $cutend{$id} = $end;
    $cutstrand{$id} = $strand;
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
        eachseq($id, $seq);
        ($id) = split(/\s/, $');  #');
        $seq = "";
    } else {
        $seq .= $_;
    }
}
eachseq($id, $seq);
close(IN);

if(scalar(keys %found) < scalar(keys %cutstart)) {
    print STDERR "Not all regions found: missing ".(scalar(keys %cutstart)-scalar(keys %found))."\n";
}
