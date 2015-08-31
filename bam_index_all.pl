#!/usr/bin/env perl
use strict;

# Requires samtools: http://samtools.sourceforge.net/
my $samtools = "samtools";

my @bamfiles = @ARGV;

unless(scalar(@bamfiles) > 0) {
    die "Usage: $0 [BAM file(s)]\n";
}

foreach my $bamfile (@bamfiles) {
    chomp $bamfile;
    
    if(-e $bamfile) {
        my $run = "$samtools index $bamfile";
        print STDERR $run."\n";
        system($run);
        
    } else {
        print STDERR "Unable to find BAM file: $bamfile\n";
    }
}
