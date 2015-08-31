#!/usr/bin/env perl
use strict;

my $infile = shift;

unless($infile) {
    die "Usage: $0 [Text file]\nOverwrite file with all non-printable characters converted to white space.\n";
}

my $str = "";

open(IN, $infile) or die "Unable to open file $infile\n";
while(<IN>) {
    $str .= $_;
}
close(IN);

$str =~ s/[\r\n]+/\n/g;
$str =~ s/[^\x20-\x7E\n\t]+/ /g;

open(OUT, ">$infile") or die "Unable to write to file $infile\n";
print OUT $str;
close(OUT);
