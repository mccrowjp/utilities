#!/usr/bin/env perl
use strict;

my @files = @ARGV;
my $file;

unless(scalar(@files) >= 1) {
    die "Usage: $0 [Fasta file(s)...]\n";
}

print "File\tSeqs\tMin\tQ1\tMedian\tQ3\tMax\tMean\tSd\n";

foreach $file (@files) {
    my $len=0;
    my @lengths=();
    my $sum=0;
    my $sumsqdiff=0;
    my $mean=0;
    my $sd=0;
    
    open(IN, $file) or die "Unable to open file $file\n";
    while(<IN>) {
        chomp;
        if(/^>/) {
            if($len > 0) {
                push(@lengths, $len);
                $sum += $len;
            }
            $len = 0;
        } else {
            my $str = $_;
            $str =~ s/[\s\*\-]//g;
            $len += length($_);
        }
    }
    close(IN);
    
    if($len > 0) {
        push(@lengths, $len);
        $sum += $len;
    }
    
    if(scalar(@lengths) > 0) {
        my $n = scalar(@lengths);
        
        $mean = $sum / $n;
        
        foreach $len (@lengths) {
            $sumsqdiff += (($len - $mean) * ($len - $mean));
        }
        
        $sd = sqrt($sumsqdiff / $n);
        
        my @sortlens = sort {$a<=>$b} @lengths;
        my $min = $sortlens[0];
        my $max = $sortlens[$n-1];
        my $q1 = ($n % 4 == 0) ? ($sortlens[int($n/4)]+$sortlens[int($n/4)+1])/2 : $sortlens[int($n/4)];
        my $q2 = ($n % 2 == 0) ? ($sortlens[int($n/2)]+$sortlens[int($n/2)+1])/2 : $sortlens[int($n/2)];
        my $q3 = ($n % 4 == 0) ? ($sortlens[int($n*3/4)]+$sortlens[int($n*3/4)+1])/2 : $sortlens[int($n*3/4)];
        
        printf join("\t", ("%s","%d","%d","%.1f","%.1f","%.1f","%d","%.1f","%.1f"))."\n", $file, $n, $min, $q1, $q2, $q3, $max, $mean, $sd;
    }
}
