#!/usr/bin/env perl
use strict;

my $infile = shift;
my $minlen = shift;
my $maxlen = shift;

my $seq = "";
my $head = "";
my $maxinf = (length($maxlen) == 0);

sub eachseq {
    $seq =~ s/[\s\t\r\n]//g;
    if(length($seq) > $minlen) {
        if($maxinf || length($seq) <= $maxlen) {
            print $head."\n".$seq."\n";
        }
    }
}

###

unless($infile && length($minlen) > 0) {
    die "Usage: $0 [FASTA file (or .gz)] [min length] ([max length])\n";
}

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

while(<IN>) {
    chomp;
    if(/^>/) {
        eachseq();
        $seq="";
        $head = $_;
    } else {
        $seq .= $_;
    }
}
eachseq();

close(IN);
