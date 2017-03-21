#!/usr/bin/env perl
use strict;

my $fqfile = shift;
my $ratio = shift;

unless($fqfile && $ratio > 0 && $ratio < 1) {
    die "Usage: $0 [FASTQ file] [sample ratio (0-1)]\n";
}

if($fqfile =~ /\.gz$/) {
    open(IN, "gunzip -c $fqfile 2>/dev/null |");
} else {
    open(IN, $fqfile) or die "Unable to open file $fqfile\n";
}
my $fn = 0;
my $write = 0;
while(<IN>) {
    $fn++;
    if($fn > 4) {
	$fn = 1;
    }
    if($fn == 1) {
	$write = (rand() < $ratio);
    }
    if($write) {
	print $_;
    }
}
close(IN);
