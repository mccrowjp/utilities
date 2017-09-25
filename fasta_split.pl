#!/usr/bin/env perl
use strict;
use Getopt::Long;

my $infa;
my $numfiles;
my $numseqs;
my $outbase;

my $totseqs = 0;

GetOptions ("i=s" => \$infa,
            "f=i" => \$numfiles,
            "s=i" => \$numseqs,
            "o=s" => \$outbase);

my $help = <<HELP;
Split FASTA into multiple files: base name_#

Usage: $0 (options)

  Required:
    -i file : Input FASTA file
    -o path : Output FASTA base name
  Must specify one of the following:
    -f int  : Number of files
    -s int  : Number of sequences

HELP

unless($infa && $outbase && ($numfiles > 0 || $numseqs > 0)) {
    die $help;
}

print "Reading $infa\n";

unless($numseqs > 0) {
    
    if($infa =~ /\.gz$/) {
        open(IN, "gunzip -c $infa 2>/dev/null |");
    } else {
        open(IN, $infa) or die "Unable to open file $infa\n";
    }
    
    while(<IN>) {
        if(/^>/) {
            $totseqs++;
        }
    }
    close(IN);
    
    $numseqs = int($totseqs / $numfiles)+1;
}

print "Splitting $totseqs sequences into $numfiles files (<= $numseqs per file)\n";

my $fnum = 1;
my $outfile = $outbase."_".$fnum;
my $i=0;
open(OUT, ">".$outfile) or die "Unable to write to file $outfile\n";

if($infa =~ /\.gz$/) {
    open(IN, "gunzip -c $infa 2>/dev/null |");
} else {
    open(IN, $infa) or die "Unable to open file $infa\n";
}

while(<IN>) {
    if(/^>/) {
        $i++;
        if($i>$numseqs) {
            close(OUT);
            $fnum++;
            $outfile = $outbase."_".$fnum;
            open(OUT, ">".$outfile) or die "Unable to write to file $outfile\n";
            $i=1;
        }
    }
    print OUT $_;
}
close(IN);
close(OUT);
