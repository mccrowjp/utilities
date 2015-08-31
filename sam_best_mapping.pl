#!/usr/bin/env perl
use strict;

my $samfile = shift;

unless($samfile) {
    die "Usage: $0 [SAM file (- for STDIN)]\n";
}

if($samfile eq '-') {
    open(IN, "<&=STDIN") or die "Unable to read from STDIN\n";
} else {
    open(IN, $samfile) or die "Unable to open file $samfile\n";
}

print join("\t", ("query_id", "ref_id", "ref_start", "ref_end", "align_cigar"))."\n";
while(<IN>) {
    my ($readid, $flag, $ctgid, $start, $mq, $cigar) = split(/\t/);
    # consider only primary alignments
    unless(/^\@/) {
        if(($flag & 0x900) == 0) {
            my $len = 0;
            my @cigvals = split(/([^\d])/, $cigar);
            
            for(my $i=0; $i<scalar(@cigvals); $i+=2) {
                my $n = $cigvals[$i];
                my $c = $cigvals[$i+1];
                if($c =~ /[MDNSH\=X]/) {
                    $len += $n;
                }
            }
            if($len > 0) {
                print join("\t", ($readid, $ctgid, $start, $start+$len-1, $cigar))."\n";
            }
        }
    }
}
close(IN);
