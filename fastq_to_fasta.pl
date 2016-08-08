#!/usr/bin/env perl
use strict;
use Getopt::Long;

my $infile;
my $outfile;
my $showhelp = 0;

GetOptions ("i=s" => \$infile,
            "o=s" => \$outfile,
            "h" => \$showhelp);

my $help = <<HELP;
FASTQ direct conversion to FASTA (ignore quality scores)

Usage: $0 (options)

  -i file : Input fastq file ('-' for STDIN)
  -o file : Output fasta file ('-' for STDOUT, default)

HELP

if($showhelp || !defined($infile)) {
    die $help;
}

if(length($outfile) == 0 || $outfile eq '-') {
    open(OUT, ">&=STDOUT") or die "Unable to write to STDOUT\n";
} else {
    open(OUT, ">".$outfile) or die "Unable to write to file $outfile\n";
}

if($infile eq '-') {
    open(IN, "<&=STDIN") or die "Unable to open STDIN\n";
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

my $sn = 0;
do {
    $sn++;
    if(defined($_ = <IN>)) {
        chomp;
        if($sn == 1) {
            if(/^\@/) {
                print OUT ">".$'."\n";  #';
            } else {
                print OUT ">".$_."\n";
            }
        } elsif($sn == 2) {
            print OUT $_."\n";
        }
    }
    if($sn >= 4) {
        $sn = 0;
    }
} until(eof IN);
