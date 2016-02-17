#!/usr/bin/env perl
use strict;

my $bamfile = shift;
my $reffile = shift;

my $help = <<HELP;
Usage: $0 [BAM file] ([ref FASTA file])

  Input:
    If BAM file has '=' in place of identical bases (from samtools calmd), then only BAM is needed.
    Otherwise, optional ref FASTA file parameter is needed for the conversion.

  Output:
    Tab delimited table of read counts, and average percent identity for each ID

HELP

unless($bamfile) {
    die $help;
}

my %readcount;
my %totlen;
my %identlen;

if(length($reffile) > 0) {
    open(IN, "samtools calmd -eu $bamfile $reffile | samtools view -F 4 - 2>/dev/null |");
} else {
    open(IN, "samtools view -F 4 $bamfile 2>/dev/null |");
}
while(<IN>) {
    chomp;
    my ($qname, $flag, $rname, $pos, $mapq, $cigar, $rnext, $pnext, $tlen, $seq, $qual) = split(/\t/);
    my $len = length($seq);
    my $mmstr = $seq;
    $mmstr =~ s/\=//g;
    my $identlen = $len - length($mmstr);
    
    if($len > 0) {
	$readcount{$rname}++;
	$totlen{$rname} += $len;
	$identlen{$rname} += $identlen;
    }
}
close(IN);

print join("\t", ('id','reads','ave_identity'))."\n";
my $format = join("\t", ('%s','%d','%.1f'))."\n";

foreach my $rname (sort keys %readcount) {
    printf $format, $rname, $readcount{$rname}, 100.0 * $identlen{$rname} / $totlen{$rname};
}
