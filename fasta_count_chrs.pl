#!/usr/bin/env perl
use strict;

my $id;
my $lastid;
my $str;

my %chrcount;

sub eachseq {
    my @chrs = split(//, $str);
    foreach my $c (@chrs) {
        $chrcount{$c}++;
    }
}

###

my $infile = shift;

if($infile) {
} else {
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
        ($id) = split(/\s/, $');  #');
        eachseq();
        $lastid = $id;
        $str = "";
    } else {
        s/[\s\t\r\n]//g;
        $str .= $_;
    }
}
eachseq();

close(IN);

foreach my $c (sort {$chrcount{$b}<=>$chrcount{$a}} keys %chrcount) {
    print $c."\t".$chrcount{$c}."\n";
}
