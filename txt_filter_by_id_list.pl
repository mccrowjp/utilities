#!/usr/bin/env perl
use strict;

my $inidlist = shift;
my $infile = shift;

my %ids;

unless($inidlist && $infile) {
    die "Usage: $0 [ID list file] [input file]\nIDs match on first column in input file separated by tab, space, or comma\n";
}

open(IN, $inidlist) or die "Unable to open file $inidlist\n";
while(<IN>) {
    chomp;
    $ids{$_} = 1;
}
close(IN);

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}
while(<IN>) {
    my ($val) = split(/[\t\s,]/);
    if($ids{$val}) {
        print $_;
    }
}
close(IN);
