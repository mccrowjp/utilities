#!/usr/bin/env perl
use strict;

my $infile = shift;
my $str;

open(IN, $infile) or die "Unable to open file $infile\n";
while(<IN>) {
    $str .= $_;
}
close(IN);

$str =~ s/\"//g;
chomp $str;
$str .= "\n";

open(OUT, ">$infile") or die "Unable to write to file $infile\n";
print OUT $str;
close(OUT);
