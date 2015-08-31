#!/usr/bin/env perl
use strict;
# Requires samtools: http://samtools.sourceforge.net/

my $bamfile = shift;

unless($bamfile) {
    die "Usage: $0 [BAM file]\n";
}

my %maxpos;
my %allrnames;
my %coverage;

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
        $allrnames{$rname} = 1;
        if($end > $maxpos{$rname}) {
            $maxpos{$rname} = $end;
        }
        
        for(my $i=$pos; $i<=$end; $i++) {
            $coverage{$rname}{$i}++;
        }
    }
    
}
close(IN);

foreach my $rname (sort keys %allrnames) {
    for(my $i=1; $i<=$maxpos{$rname}; $i++) {
        print join("\t", ($rname, $i, 0+$coverage{$rname}{$i}))."\n";
    }
}
