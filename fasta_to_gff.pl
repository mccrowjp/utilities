#!/usr/bin/env perl
use strict;
use Getopt::Long;

my $gff_source = 'fasta_to_gff';
my $gff_feature = 'gene';
my $gff_frame = '0';
my $gff_score = '.';

GetOptions ("s=s" => \$gff_source,
            "f=s" => \$gff_feature);

my $fafile = shift;

my $help = <<HELP;
Usage: $0 (options) [FASTA file (- for STDIN)]

  FASTA IDs have format returned by FragGeneScan or similar 
  (eg. contig_1234_5_200_+  with start, end, and strand separated by '_')
  
  -s text  : Source to list (project, database, or program name)
             [Default: fasta_to_gff]

  -f text  : Feature type (typical values: gene, transcript, CDS, exon)
             [Default: gene]

HELP

unless($fafile) {
    die $help;
}

if($fafile eq '-') {
    open(IN, "<&=STDIN") or die "Unable to read from STDIN\n";
} elsif($fafile =~ /.gz$/) {
    open(IN, "gunzip -c $fafile 2>/dev/null |");
} else {
    open(IN, $fafile) or die "Unable to open file $fafile\n";
}

while(<IN>) {
    chomp;

    if(/^>([^\s]+)_(\d+)_(\d+)_([\+\-])$/) {
	my $gff_chr = $1;
	my $gff_s = $2;
	my $gff_e = $3;
	my $gff_strand = $4;
	my $gff_attr = $gff_feature."_id \"".join('_', ($gff_chr, $gff_s, $gff_e, $gff_strand))."\"";
	
	print join("\t", ($gff_chr, $gff_source, $gff_feature, $gff_s, $gff_e, $gff_score, $gff_strand, $gff_frame, $gff_attr))."\n";
    }
}
close(IN);
