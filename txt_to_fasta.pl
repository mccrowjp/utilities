#!/usr/bin/env perl
use strict;

my $infile = shift;

unless($infile) {
    die "Usage: $0 [Tab-delimited table (.gz)]\n";
}

if($infile eq '-') {
    open(IN, "<&=STDIN") or die "Unable to open STDIN\n";
} elsif($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

my $fl = 1;
while(<IN>) {
    chomp;
    unless($fl) {
        my @cols = split(/\t/);
        my $seq = pop(@cols);
        print ">".join("\t", (@cols))."\n".$seq."\n";
    }
    $fl = 0;
}
