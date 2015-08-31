#!/usr/bin/env perl
use strict;

my ($patfile, $infile, @optlist) = @ARGV;

my $options = join(" ", @optlist);

if($patfile && $infile) {
} else {
    die "Usage: $0 [pattern list file] [text file] ([grep options ...])\n";
}

open(IN, $patfile) or die "Unable to open file $patfile\n";
while(<IN>) {
    chomp;
    my $pat = $_;
    if(length($pat) > 0) {
        system("grep $options $pat $infile");
    }
}
close(IN);
