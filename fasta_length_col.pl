#!/usr/bin/env perl
use strict;

my $id = "";
my $len = 0;

sub eachseq {
    if(length($id) > 0) {
        print join("\t", ($id, $len))."\n";
    }
}

###

my $infile = shift;

unless($infile) {
    die "Usage: $0 [FASTA file (or .gz)]\n";
}

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

while(<IN>) {
    chomp;
    if(/^>/) {
        eachseq();
        ($id) = split(/[\s\t]/, $');  #');
        $len=0;
    } else {
        my $str = $_;
        $str =~ s/[\*\s]//g;
        $len += length($str);
    }
}
eachseq();

close(IN);
