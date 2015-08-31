#!/usr/bin/env perl
use strict;

# Requires samtools: http://samtools.sourceforge.net/
my $samtools = "samtools";

my $bamfile = shift;

unless($bamfile) {
    die "Usage: $0 [BAM file]\n";
}

exec("$samtools view -F 4 $bamfile");
