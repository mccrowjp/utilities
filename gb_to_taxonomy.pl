#!/usr/bin/env perl
use strict;

my $infile = shift;

unless($infile) {
    die "Usage: $0 [Genbank file]\n";
}

my $acc;
my @taxlist;
my $sp;
my $taxstr;
my $readorg = 0;

open(IN, $infile) or die "Unable to open file $infile\n";
while(<IN>) {
    chomp;
    if(/^LOCUS/) {
        if(length($acc) > 0 && length($taxstr) > 0) {
            print $acc."\t".$taxstr."\n";
        }
        $acc = "";
        @taxlist = ();
        $sp = "";
        $taxstr = "";
    }
    unless(/^\s/) {
        $readorg = 0;
    }
    if($readorg) {
        s/\.$//;
        foreach my $t (split(/;/)) {
            $t =~ s/^\s+//;
            $t =~ s/\s+$//;
            push(@taxlist, $t);
        }
        $taxstr = join(";", (@taxlist, $sp));
    }
    if(/^ACCESSION/) {
        my ($key, $val) = split(/\s+/);
        $acc = $val;
    }
    if(/^\s*ORGANISM/) {
        $readorg = 1;
        $sp = $';
        $sp =~ s/^\s+//;
        $sp =~ s/\s+$//;
    }
}
if(length($acc) > 0 && length($taxstr) > 0) {
    print $acc."\t".$taxstr."\n";
}
close(IN);
