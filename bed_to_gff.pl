#!/usr/bin/env perl
use strict;
use Getopt::Long;

my $gff_source = 'bed_to_gff';
my $gff_feature = 'gene';
my $gff_frame = '0';


GetOptions ("s=s" => \$gff_source,
            "f=s" => \$gff_feature);

my $bedfile = shift;

my $help = <<HELP;
Usage: $0 (options) [BED file (- for STDIN)]

  -s text  : Source to list (project, database, or program name)
             [Default: bed_to_gff]

  -f text  : Feature type (typical values: gene, transcript, CDS, exon)
             [Default: gene]

HELP

unless($bedfile) {
    die $help;
}

if($bedfile eq '-') {
    open(IN, "<&=STDIN") or die "Unable to read from STDIN\n";
} else {
    open(IN, $bedfile) or die "Unable to open file $bedfile\n";
}

while(<IN>) {
    chomp;
    my $gff_chr = '.';
    my $gff_s = '.';
    my $gff_e = '.';
    my $gff_score = '.';
    my $gff_strand = '.';
    my $gff_attr = "";
    
    my ($chr, $chr_s, $chr_e, $name, $score, $strand, $thick_s, $thick_e, $item_RGB, $blk_count, $blk_sizes, $blk_s) = split(/\t/);
    
    if(length($chr) > 0) {
        $gff_chr = $chr;
    }
    if(length($chr_s) > 0) {
        $gff_s = $chr_s;
    }
    if(length($chr_e) > 0) {
        $gff_e = $chr_e;
    }
    if(length($score) > 0) {
        $gff_score = $score
    }
    if(length($strand) > 0) {
        $gff_strand = $strand;
    }
    if(length($name) > 0) {
        $gff_attr = $gff_feature."_id \"".$name."\"";
    }

    print join("\t", ($gff_chr, $gff_source, $gff_feature, $gff_s, $gff_e, $gff_score, $gff_strand, $gff_frame, $gff_attr))."\n";
}
close(IN);
