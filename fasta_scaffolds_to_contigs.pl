#!/usr/bin/env perl
#
# Splits sequences in FASTA on strings of N's
#

use strict;
use Getopt::Long;

my $readSTDIN;
my $infile;
my $outfile;
my $minnlen = 10;
my $showhelp;

sub splitseq {
    my ($id, $head, $seq) = @_;
    my $nm1 = $minnlen-1;
    
    $seq =~ s/ //g;
    if(length($seq) > 0) {
        my @ctgs = split(/[nN]{$nm1}[nN]+/, $seq);
        if(scalar(@ctgs) == 1) {
            print OUT ">".join(" ", ($id, $head))."\n$seq\n";
        } elsif(scalar(@ctgs) > 1) {
            my $i=0;
            foreach my $ctg (@ctgs) {
                if(length($ctg) > 0) {
                    $i++;
                    print OUT ">".join(" ", ($id."_".$i, $head))."\n".$ctg."\n";
                }
            }
        }
    }
}

###

GetOptions ("s" => \$readSTDIN,
            "i=s" => \$infile,
            "o=s" => \$outfile,
            "n=i" => \$minnlen,
            "h"   => \$showhelp);

my $help = <<HELP;
Usage: $0 [fasta file] (options)
    -s      : input from STDIN
    -i file : input fasta file

    -o file : output fasta file (default: STDOUT)

    -n len  : minimum length of Ns to split on (default: 10)
    
    -h      : Help

HELP

if(length($ARGV[0]) > 0) {
    $infile = $ARGV[0];
}

if($showhelp || !(length($infile) > 0 || $readSTDIN)) {
    die $help;
}

if(length($infile) > 0) {
    open(IN, $infile) or die "Unable to open file $infile\n";
} else {
    open(IN, "<&=STDIN") or die "Unable to read from STDIN\n";
}

if(length($outfile) > 0) {
    open(OUT, ">".$outfile) or die "Unable to write to file $outfile\n";
} else {
    open(OUT, ">&=STDOUT") or die "Unable to write to STDOUT\n";
}

my @rest;
my $head;
my $id;
my $seq;
while(<IN>) {
    chomp;
    if(/^\#/) {
        } else {
            if(/^>/) {
                splitseq($id, $head, $seq);
                ($id, @rest) = split(/\s/, $');   #');
                $head = join(" ", @rest);
                $seq = "";
            } else {
                $seq .= $_;
            }
        }
}
splitseq($id, $head, $seq);

close(IN);
close(OUT);
