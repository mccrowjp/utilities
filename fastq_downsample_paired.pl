#!/usr/bin/env perl
use strict;

my ($infile1, $infile2, $ratio, $outfile1, $outfile2) = @ARGV;

unless($infile1 && $infile2 && $outfile1 && $outfile2 && $ratio > 0 && $ratio < 1) {
    die "Usage: $0 [FASTQ file 1] [FASTQ file 2] [sample ratio (0-1)] [Output file 1] [Output file 2]\n";
}

if(-e $outfile1 || -e $outfile2) {
    die "Output files already exist\n";
}

if($infile1 =~ /\.gz$/) {
    open(IN1, "gunzip -c $infile1 2>/dev/null |");
} else {
    open(IN1, $infile1) or die "Unable to open file $infile1\n";
}

if($infile2 =~ /\.gz$/) {
    open(IN2, "gunzip -c $infile2 2>/dev/null |");
} else {
    open(IN2, $infile2) or die "Unable to open file $infile2\n";
}

open(OUT1, ">".$outfile1) or die "Unable to write to file $outfile1\n";
open(OUT2, ">".$outfile2) or die "Unable to write to file $outfile2\n";

my $fn = 0;
my $write = 0;
my $line2 = "";

while(<IN1>) {
    $line2 = <IN2>;
    
    $fn++;
    if($fn > 4) {
	    $fn = 1;
    }
    if($fn == 1) {
	    $write = (rand() < $ratio);
    }
    if($write) {
	    print OUT1 $_;
	    print OUT2 $line2;
    }
}
close(IN1);
close(IN2);

close(OUT1);
close(OUT2);
