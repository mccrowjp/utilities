#!/usr/bin/env perl
use strict;

my $infile = shift;

unless($infile) {
    die "Usage: $0 [Tab-delimited file with first line header]\n";
}

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

my @cols = split(/\t/, <IN>);
for(my $i=0; $i<scalar(@cols); $i++) {
    printf "%d\t%s\n", $i+1, $cols[$i];
}
