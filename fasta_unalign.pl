#!/usr/bin/env perl
use strict;

sub print_unalign {
    my $str = shift;
    if(length($str) > 0) {
        $str =~ s/[^A-Za-z]//g;
        print $str."\n";
    }
}

###

my $fafile = shift;

unless($fafile) {
    die "Usage: $0 [multiple alignment FASTA]\n  output: FASTA\n";
}

my $seq = "";
if($fafile =~ /\.gz$/) {
    open(IN, "gunzip -c $fafile 2>/dev/null |");
} else {
    open(IN, $fafile) or die "Unable to open file $fafile\n";
}
while(<IN>) {
    chomp;
    if(/^>/) {
        print_unalign($seq);
        print $_."\n";
        $seq = "";
    } else {
        $seq .= $_;
    }
}
print_unalign($seq);

close(IN);
