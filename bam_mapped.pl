#!/usr/bin/env perl
use strict;

# Requires samtools: http://samtools.sourceforge.net/
my $samtools = "samtools";

sub run($) {
    my $exe = shift;
    chomp $exe;
    print STDERR $exe."\n";
    system($exe);
}

my @bamfiles = @ARGV;

unless(scalar(@bamfiles) > 0) {
    die "Usage: $0 [BAM file(s)]\n";
}

foreach my $bamfile (@bamfiles) {
    if(-e $bamfile) {
        my $basefile = $bamfile;
        $basefile =~ s/.+\///g;
        $basefile =~ s/\.(bam|sam)$//i;
        my $msfile = $basefile."_mapped.bam";
        
        run("$samtools view -F 4 -b $bamfile > $msfile");

    } else {
        print STDERR "Unable to find BAM file: $bamfile\n";
    }
}
