#!/usr/bin/env perl
use strict;

my $id;
my $lastid;
my $str;

my %ncount;
my %tcount;

sub eachseq {
    if(length($str) > 0) {
        $str =~ s/[^A-Za-z]//g;
        my $n = scalar(split(/[nN]/, $str))-1;
        $tcount{$lastid} = length($str);
        $ncount{$lastid} = $n;
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

print "id\tlength\tN\t%N\n";
foreach my $id (sort keys %ncount) {
    printf "%s\t%d\t%d\t%.2f\n", $id, $tcount{$id}, $ncount{$id}, $tcount{$id}>0 ? 100.0*$ncount{$id}/$tcount{$id} : 0;
}
