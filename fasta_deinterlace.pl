#!/usr/bin/env perl
use strict;
use Getopt::Long;

my $infile;
my $outbase;
my $showhelp = 0;

GetOptions ("i=s" => \$infile,
	    "o=s" => \$outbase,
	    "h" => \$showhelp);

my $help = <<HELP;
Interlaced FASTA converted to 2 non-interlaced FASTA files

Usage: $0 (options)

    -i file : Input interlaced FASTA file (default: STDIN)
    -o file : Output base name (output: base_R1.fasta and base_R2.fasta)

HELP

if($showhelp || !$outbase) {
    die $help;
}

my $outfile1 = $outbase."_R1.fasta";
my $outfile2 = $outbase."_R2.fasta";
open(OUT1, ">".$outfile1) or die "Unable to write to file $outfile1\n";
open(OUT2, ">".$outfile2) or die "Unable to write to file $outfile2\n";

if(length($infile) > 0) {
    if($infile =~ /\.gz$/) {
	open(IN, "gunzip -c $infile 2>/dev/null |");
    } else {
	open(IN, $infile) or die "Unable to open file $infile\n";
    }
} else {
    open(IN, "<&=STDIN") or die "Unable to open STDIN\n";
}

my $num = 2;

while(<IN>) {
    if(/^>/) {
	$num = ($num==1 ? 2 : 1);
    }
    if($num == 1) {
	print OUT1 $_;
    }
    if($num == 2) {
	print OUT2 $_;
    }
}
