#!/usr/bin/env perl
use strict;
use Getopt::Long;

my $infile;
my $ratio;
my $hasheader = 0;

my $help = <<HELP;
Usage: $0 (options)

  -i file  : Input file name
  -r real  : Sample ratio (0,1)
  -h       : Input file has header row (default: False)

HELP

GetOptions ("i=s" => \$infile,
            "r=f" => \$ratio,
            "h" => \$hasheader);

unless($infile && $ratio > 0 && $ratio < 1) {
    die $help;
}

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}
while(<IN>) {
    if(rand() < $ratio) {
        print $_;
    }
}
close(IN);
