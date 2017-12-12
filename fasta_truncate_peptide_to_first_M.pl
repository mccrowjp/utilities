#!/usr/bin/env perl
use strict;

my $head;
my $lasthead;
my $str;

my $count_total = 0;
my $count_trunc = 0;
my $count_remove = 0;

sub eachseq {
    if(length($str) > 0) {
        $count_total++;
        
        unless($str =~ /^[Mm]/) {
            if($str =~ /^[^Mm]+([Mm].+)$/) {
                $str = $1;
                $count_trunc++;
            } else {
                $str = "";
                $count_remove++;
            }
        }
        if(length($str) > 0) {
            print ">".$lasthead."\n".$str."\n";
        }
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

printf STDERR "Total    : %d\n", $count_total;
printf STDERR "Truncated: %d (%.1f \%)\n", $count_trunc, 100.0*$count_trunc/$count_total;
printf STDERR "Removed  : %d (%.1f \%)\n", $count_remove, 100.0*$count_remove/$count_total;
