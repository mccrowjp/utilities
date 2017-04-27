#!/usr/bin/env perl
use strict;
use Getopt::Long;

my $gff_source = 'fasta_to_gff_full_length';
my $gff_feature = 'gene';
my $gff_frame = '0';
my $gff_score = '.';

GetOptions ("s=s" => \$gff_source,
            "f=s" => \$gff_feature);

my $fafile = shift;

my $help = <<HELP;
Usage: $0 (options) [FASTA file (- for STDIN)]

  Each sequence in FASTA is given a full length feature in GFF output
  
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

my $id;
my %seqlen;

while(<IN>) {
    chomp;
    if(/^>/) {
        ($id) = split(/[\s\t\r\n]/, $');
    } else {
        s/[^a-zA-Z]//g;
        $seqlen{$id} += length($_);
    }
}
close(IN);

foreach my $id (sort keys %seqlen) {
    my $gff_chr = $id;
    my $gff_s = 1;
    my $gff_e = $seqlen{$id};
    my $gff_strand = "+";
    my $gff_attr = $gff_feature."_id \"".$id."\"";

    print join("\t", ($gff_chr, $gff_source, $gff_feature, $gff_s, $gff_e, $gff_score, $gff_strand, $gff_frame, $gff_attr))."\n";
}
