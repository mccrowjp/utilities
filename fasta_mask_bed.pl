#!/usr/bin/env perl
use strict;

my %maskctg;
my %maskstart;
my %maskend;
my %ctgids;
my %found;

sub eachseq {
    my ($head, $seq) = @_;
    my ($id) = split(/\s/, $head);
    $seq =~ s/[^A-Za-z]//g;

    if(length($seq) > 0) {
        foreach my $mask (@{$ctgids{$id}}) {
            if(exists($maskstart{$mask}) && exists($maskend{$mask})) {
                $found{$mask} = 1;
                my $s = $maskstart{$mask}-1;
                my $e = $maskend{$mask}-1;
                my $len = $e - $s + 1;
                my $str_ins = 'N' x $len;
                my $str_left = $s > 0 ? substr($seq, 0, $s) : "";
                my $str_del = substr($seq, $s, $len);
                my $str_right = $e < length($seq)-1 ? substr($seq, $e+1, length($seq)-$e-1) : "";
                
                if(length($str_del) == length($str_ins) && length($str_left) + length($str_ins) + length($str_right) == length($seq)) {
                    $seq = $str_left.$str_ins.$str_right;
                    
                } else {
                    die "Unable to mask region $id ".$maskstart{$mask}." - ".$maskend{$mask}."\n";
                }
            }
        }
        
        print ">".$head."\n".$seq."\n";
    }
}

###

my $infile = shift;
my $bedfile = shift;

unless($infile && $bedfile) {
    die "Usage: $0 [FASTA file (or .gz)] [BED file]\nOutput FASTA with all regions specified in BED file masked\n";
}

my $masknum = 0;
open(IN, $bedfile) or die "Unable to open file $bedfile\n";
while(<IN>) {
    chomp;
    my ($ctg, $start, $end) = split(/\t/);
    $masknum++;
    $maskctg{$masknum} = $ctg;
    $maskstart{$masknum} = $start;
    $maskend{$masknum} = $end;
    push(@{$ctgids{$ctg}}, $masknum);
}
close(IN);

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

my $head;
my $seq;
while(<IN>) {
    chomp;
    if(/^>/) {
        eachseq($head, $seq);
        $head = $';
        $seq = "";
    } else {
        $seq .= $_;
    }
}
eachseq($head, $seq);
close(IN);

if(scalar(keys %found) < scalar(keys %maskstart)) {
    print STDERR "Not all regions found: missing ".(scalar(keys %maskstart)-scalar(keys %found))."\n";
}
