#!/usr/bin/env perl
use strict;
use Getopt::Long;
# Requires samtools: http://samtools.sourceforge.net/

my $isbamout = 0;
my $minq_primary = 30;   # primary hit minimum alignment quality
my $minq_secondary = 0; # exclude reads with secondary hits at or above this score 
my $flag_not_mapped = 4;
my $flag_not_primary = 4096;
my $flag_secondary = 256;

GetOptions ("q=i" => \$minq_primary,
            "u=i" => \$minq_secondary,
            "b"   => \$isbamout);

my $bamfile = shift;

my $help = <<HELP;
Usage: $0 (options) [BAM file (- for STDIN)]

    -q int   : Minimum alignment quality (MINQ) (Usually 0-60)
               [Default: 30]

    -u int   : Minimum quality of secondary hits (Usually 0-60)
               [Default: 0]

    -b       : BAM output

HELP

unless($bamfile) {
    die $help;
}

my %excluderead;
my $count_good = 0;
my $count_total = 0;

open(IN, "samtools view -F $flag_not_mapped -q $minq_secondary $bamfile 2>/dev/null |");
while(<IN>) {
    chomp;
    my ($qname, $flag, $rname, $pos, $mapq, $cigar, $rnext, $pnext, $tlen, $seq, $qual) = split(/\t/);
    my $isprimary = ($flag & $flag_not_primary) == 0 && ($flag & $flag_secondary) == 0;
    
    $count_total++;
    unless($isprimary) {
        $excluderead{$qname} = 1;
    }
}
close(IN);

print STDERR "Total reads primary/secondary: $count_total\n";
print STDERR "Excluding non-uniquely mapped reads (Q".$minq_secondary."): ".scalar(keys %excluderead)."\n";

if($isbamout) {
    open(OUT, "| samtools view -b -");
} else {
    open(OUT, ">&=STDOUT");
}

open(IN, "samtools view -h -F $flag_not_mapped -q $minq_primary $bamfile 2>/dev/null |");
while(<IN>) {
    chomp;
    my ($qname, $flag, $rname, $pos, $mapq, $cigar, $rnext, $pnext, $tlen, $seq, $qual) = split(/\t/);
    my $isprimary = ($flag & $flag_not_primary) == 0 && ($flag & $flag_secondary) == 0;

    if(/^\@/ || ($isprimary && !$excluderead{$qname})) {	
        print OUT $_."\n";
    }
}
close(IN);
close(OUT);

print STDERR "Filtered reads (Q".$minq_primary."): $count_good\n";
