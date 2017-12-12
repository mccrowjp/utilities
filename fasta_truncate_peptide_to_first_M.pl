#!/usr/bin/env perl
use strict;

my $head;
my $lasthead;
my $str;

sub eachseq {
    unless($str =~ /^[Mm]/) {
        if($str =~ /^[^Mm]+([Mm].+)$/) {
            $str = $1;
        } else {
            $str = "";
        }
    }
    if(length($str) > 0) {
        print ">".$lasthead."\n".$str."\n";
    }
}

###

my $infile = shift;

unless($infile) {
    die "Usage: $0 [fasta file (or .gz)]\n";
}

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

while(<IN>) {
    chomp;
    if(/^>/) {
        $head = $';
        eachseq();
        $lasthead = $head;
        $str = "";
    } else {
        s/[\s\t\r\n]//g;
        $str .= $_;
    }
}
eachseq();

close(IN);
