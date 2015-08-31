#!/usr/bin/env perl
use strict;
use LWP::Simple;

my $in1 = shift;
my $in2 = shift;

my $accfile = "";
my $colnum = 1;

if($in1 =~ /^\-(\d+)$/) {
    $colnum = $1;
    $accfile = $in2;
} else {
    $accfile = $in1;
}

unless(length($accfile) > 0 && $colnum >= 1) {
    die "Usage: $0 (options) [Accession number list file]\n   -#  : Column # of accession numbers (default 1)\n";
}

open(IN, $accfile) or die "Unable to open file $accfile\n";
while(<IN>) {
    chomp;
    my @cols = split(/\t/);
    my $acc = $cols[$colnum-1];
    
    if($acc =~ /^[\d\w]+$/) {
        my $xml = get "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=".$acc."&rettype=fasta&retmode=xml";
        if($xml =~ /\<TSeq_taxid\>(\d+)\<\/TSeq_taxid\>/) {
            print $acc."\t".$1."\n";
        }
    }
}
close(IN);
