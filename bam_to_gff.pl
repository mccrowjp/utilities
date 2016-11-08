#!/usr/bin/env perl
use strict;
use Getopt::Long;
# Requires samtools: http://samtools.sourceforge.net/

my $flag_not_mapped = 4;
my $flag_not_primary = 4096;
my $flag_secondary = 256;
my $flag_revcomp = 16;

my $minq_primary = 0;    # primary hit minimum alignment quality
my $minq_secondary = -1; # exclude reads with secondary hits at or above this score

my $gff_source = 'bed_to_gff';
my $gff_feature = 'EST';
my $gff_frame = '0';

my %excluderead;

GetOptions ("s=s" => \$gff_source,
            "f=s" => \$gff_feature,
            "q=i" => \$minq_primary,
            "u=i" => \$minq_secondary);

my $bamfile = shift;

my $help = <<HELP;
Usage: $0 (options) [BAM file (- for STDIN)]

  -s text  : Source to list (project, database, or program name)
             [Default: bam_to_gff]

  -f text  : Feature type (typical values: gene, transcript, CDS, exon)
             [Default: EST]

  -q int   : Minimum alignment quality (MINQ) (Usually 0-60)
             [Default: 0]

  -u int   : Unique mapping reads only. Minimum quality of secondary hits (Usually 0-60)
             [Default: allow multimapped reads, use primary mapping location]

HELP

unless($bamfile) {
    die $help;
}

if($minq_secondary =~ /^\d+$/ && $minq_secondary >= 0) {
    open(IN, "samtools view -F $flag_not_mapped -q $minq_secondary $bamfile 2>/dev/null |");
    while(<IN>) {
        chomp;
        my ($qname, $flag, $rname, $pos, $mapq, $cigar, $rnext, $pnext, $tlen, $seq, $qual) = split(/\t/);
        my $isprimary = ($flag & $flag_not_primary) == 0 && ($flag & $flag_secondary) == 0;
        
        unless($isprimary) {
            $excluderead{$qname} = 1;
        }
    }
    close(IN);
    
    print STDERR "Non-unique reads excluded: ".scalar(keys %excluderead)."\n";
}

open(IN, "samtools view -F $flag_not_mapped -q $minq_primary $bamfile 2>/dev/null |");
while(<IN>) {
    chomp;
    my ($qname, $flag, $rname, $pos, $mapq, $cigar, $rnext, $pnext, $tlen, $seq, $qual) = split(/\t/);
    my $end = $pos-1;
    my $cigstr = $cigar;
    my $isprimary = ($flag & $flag_not_primary) == 0 && ($flag & $flag_secondary) == 0;
    my $isrevcomp = ($flag & $flag_revcomp) == 1;
    
    my $gff_chr = $rname;
    my $gff_s = $pos;
    my $gff_e = '.';
    my $gff_score = '.';
    my $gff_strand = $isrevcomp ? '-' : '+';
    my $gff_attr = $gff_feature."_id \"".$qname."\"";
    
    if($isprimary && !$excluderead{$qname}) {
        while($cigstr =~ /^(\d+)([MIDNSHPX=])/) {
            my $len = $1;
            my $op = $2;
            $cigstr = $';   #';
            
            if($op =~ /[MDSHPX=]/) {
                $end += $len;
            }
        }
        
        if($end >= $pos) {
            $gff_e = $end;
            if($mapq =~ /^\d+$/) {
                $gff_score = $mapq;
            }
            print join("\t", ($gff_chr, $gff_source, $gff_feature, $gff_s, $gff_e, $gff_score, $gff_strand, $gff_frame, $gff_attr))."\n";
        }
    }
}
close(IN);
