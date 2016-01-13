#!/usr/bin/env perl
use strict;

my $bamfile = shift;

unless($bamfile) {
    die "Usage: $0 [BAM file]\n";
}

my %minpos;
my %maxpos;
my %readcount;
my %readlensum;

open(IN, "samtools view -F 4 $bamfile 2>/dev/null |");
while(<IN>) {
    chomp;
    my ($qname, $flag, $rname, $pos, $mapq, $cigar, $rnext, $pnext, $tlen, $seq, $qual) = split(/\t/);
    my $end = $pos-1;
    my $cigstr = $cigar;

    while($cigstr =~ /^(\d+)([MIDNSHPX=])/) {
	my $len = $1;
	my $op = $2;
	$cigstr = $';   #';

	if($op =~ /[MDSHPX=]/) {
	    $end += $len;
	}
    }

    if($end >= $pos) {
	if(!exists($minpos{$rname}) || $pos < $minpos{$rname}) {
	    $minpos{$rname} = $pos;
	}
	if(!exists($maxpos{$rname}) || $end > $maxpos{$rname}) {
	    $maxpos{$rname} = $end;
	}
	
	$readcount{$rname}++;
	$readlensum{$rname} += $end-$pos+1;
    }

}
close(IN);

print join("\t", ('id','reads','ave_coverage'))."\n";
foreach my $rname (sort keys %readcount) {
    my $len = $maxpos{$rname} - $minpos{$rname} + 1;
    print join("\t", ($rname, $readcount{$rname}, $readlensum{$rname} / $len))."\n";
}
