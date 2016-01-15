#!/usr/bin/env perl
use strict;

my $bamfile = shift;

unless($bamfile) {
    die "Usage: $0 [BAM file]\n";
}

my %readcount;
my %totlen;
my %identlen;

open(IN, "samtools view -F 4 $bamfile 2>/dev/null |");
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
