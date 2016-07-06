#!/usr/bin/env perl
use strict;
use Getopt::Long;

my $infile;
my $outfile;
my $quality = 50;
my $showhelp = 0;
my $minlen = 0;
my $qualchr = chr(33+$quality);

###

sub writeout {
    my ($head, $seq) = @_;
    
    $seq =~ s/[\s\t\r\n]//g;
    my $len = length($seq);
    if(length($head) > 0 && $len > 0) {
        my $qualstr = "";
        for(my $i=0; $i<$len; $i++) {
            $qualstr .= $qualchr;
        }
        if($len < $minlen) {
            for(my $i=0; $i<$minlen-$len; $i++) {
                $seq .= 'N';
                $qualstr .= chr(35);
            }
        }
        print OUT "@".$head."\n";
        print OUT $seq."\n";
        print OUT "+\n";
        print OUT $qualstr."\n";
    }
}

###

GetOptions ("i=s" => \$infile,
	    "o=s" => \$outfile,
	    "q=i" => \$quality,
        "l=i", \$minlen,
	    "h" => \$showhelp);

my $help = <<HELP;
FASTA direct conversion to FASTQ

Usage: $0 (options)

    -i file : Input FASTA file (use '-' for STDIN)
    -o file : Output FASTQ file (default: STDOUT)
    -q int  : PHRED quality score (default: 50)
    -l int  : Minimum read length, pad with N's at end of read

HELP

if(!$infile || $showhelp) {
    die $help;
}

if($infile eq '-') {
    open(IN, "<&=STDIN") or die "Unable to open STDIN\n";
} elsif($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

if(length($outfile) > 0) {
    open(OUT, ">".$outfile) or die "Unable to write to file $outfile\n";
} else {
    open(OUT, ">&=STDOUT") or die "Unable to write to STDOUT\n";
}

my $head;
my $seq;

while(<IN>) {
    chomp;
    if(/^>/) {
        writeout($head, $seq);
        $head = $';  #';
        $seq = "";
    } else {
        $seq .= $_;
    }
}
writeout($head, $seq);
