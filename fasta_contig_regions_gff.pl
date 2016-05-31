#!/usr/bin/env perl
use strict;
use Getopt::Long;

my $window_size = 1000;
my $gff_source = 'fasta_contig_regions_gff';
my $gff_feature = 'window';
my $gff_frame = '0';
my $gff_score = '.';

sub write_regions {
    my ($gff_chr, $seq) = @_;
    my $n = length($seq);
    
    if(length($gff_chr) > 0 && $n > 0) {
        for(my $i=0; $i<$n; $i+=$window_size) {
            my $gff_s = $i+1;
            my $gff_e = $i+$window_size;
            if($gff_e > $n) {
                $gff_e = $n;
            }
            my $gff_strand = "+";
            my $gff_attr = "ID \"".join('_', ($gff_chr, $gff_s, $gff_e))."\"";

            print join("\t", ($gff_chr, $gff_source, $gff_feature, $gff_s, $gff_e, $gff_score, $gff_strand, $gff_frame, $gff_attr))."\n";
        }
    }
}

###

GetOptions ("n=i" => \$window_size,
            "s=s" => \$gff_source,
            "f=s" => \$gff_feature);

my $fafile = shift;

my $help = <<HELP;
Usage: $0 (options) [FASTA file (- for STDIN)]

  Output GFF defining regions of length window_size for each FASTA sequence
  
  -n int   : window_size (default: 1000)

  -s text  : Source to list (project, database, or program name)
             [Default: fasta_contig_regions_gff]

  -f text  : Feature type (typical values: gene, transcript, CDS, exon)
             [Default: window]

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
my $seq;
while(<IN>) {
    chomp;
    if(/^>/) {
        write_regions($id, $seq);
        ($id) = split(/[\s\t\r\n]/, $');  #');
        $seq = "";
    } else {
        $seq .= $_;
    }
}
write_regions($id, $seq);
close(IN);
