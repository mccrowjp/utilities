#!/usr/bin/env perl
use strict;

my $infile = shift;
my $adaptseq = shift;

$adaptseq =~ tr/a-z/A-Z/;
my $indexlen = length($adaptseq);

unless(length($infile) > 0 && $indexlen > 0) {
    die "Usage: $0 [FASTQ file] [Adapter index sequence]\n";
}

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

my $sn = 0;
my $isgood = 0;
my $count_good = 0;
my $count_total = 0;
do {
    $sn++;
    if($sn > 4) {
        $sn = 1;
        $isgood = 0;
    }
    if(defined($_ = <IN>)) {
        chomp;
        if($sn == 1) {
            $count_total++;
            
            my $lseq = substr($_, -$indexlen);
            
            if($lseq eq $adaptseq) {
                $isgood = 1;
                $count_good++;
            }
        }
        
        if($isgood) {
            print $_."\n";
        }
    }
    
} until(eof IN);

print STDERR "Extracted: $count_good of $count_total\n";
