#!/usr/bin/env perl
use strict;

unless(scalar(@ARGV) > 0) {
    die "Usage: $0 [FASTQ file(s)...]\n";
}

foreach my $file (@ARGV) {
    if($file =~ /\.gz$/) {
        open(IN, "gunzip -c $file 2>/dev/null |");
    } else {
        open(IN, $file) or die "Unable to open file $file\n";
    }

    my $sn = 0;
    my $count = 0;
    
    while(<IN>) {
        $sn++;
        if($sn == 4) {
            $count++;
        }
        if($sn > 4) {
            $sn = 1;
        }
    }
    
    print $file."\t".$count."\n";
}
