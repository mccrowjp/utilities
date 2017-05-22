#!/usr/bin/env perl
use strict;

my $infa = shift;
my $outdir = shift;

my $help = <<HELP;
Split multi-FASTA into many single sequence FASTA files

Usage: $0 [multi-FASTA file] ([output folder])

HELP

unless($infa) {
    die $help;
}

$outdir =~ s/\/+$//;
unless(length($outdir) > 0) {
    $outdir = ".";
}

print STDERR "reading $infa\n";

if($infa =~ /\.gz$/) {
    open(IN, "gunzip -c $infa 2>/dev/null |");
} else {
    open(IN, $infa) or die "Unable to open file $infa\n";
}

my $seqnum = 0;
while(<IN>) {
    chomp;
    if(/^>/) {
        if($seqnum > 0) {
            close(OUT);
        }
        my ($id) = split(/[\s\t\r\n]/, $');
        my $outfile = $outdir."/".$id.".fa";
        open(OUT, ">".$outfile) or die "Unable to write to file $outfile\n";
        $seqnum++;
    }
    print OUT $_."\n";
}
close(IN);
close(OUT);
