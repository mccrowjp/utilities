#!/usr/bin/env perl
use strict;

my $infile = shift;

unless($infile) {
    die "Usage: $0 [BAM File]\n";
}

my $count_rows = 0;
my $count_removed = 0;
my $count_hard_remaining = 0;

open(IN, "samtools view -h $infile 2>/dev/null |");
while(<IN>) {
    chomp;
    if(/^@/) {
	print $_."\n";
    } else {
	my ($qname, $flag, $rname, $pos, $mapq, $cigar, $rnext, $pnext, $tlen, $seq, $qual, @rest) = split(/\t/);
	$count_rows++;

	my $removed = 0;
	if($cigar =~ /^\d+H(.+)$/) {
	    $cigar = $1;
	    $removed = 1;
	}
	if($cigar =~ /^(.+[A-Z])\d+H$/) {
	    $cigar = $1;
	    $removed = 1;
	}
	if($removed) {
	    $count_removed++;
	    if($cigar =~ /\d+H/) {
		$count_hard_remaining++;
	    }
	}
	print join("\t", ($qname, $flag, $rname, $pos, $mapq, $cigar, $rnext, $pnext, $tlen, $seq, $qual, @rest))."\n";
    }
}
close(IN);

print STDERR "Total rows:                    $count_rows\n";
print STDERR "Hard-clipping removed:         $count_removed\n";
print STDERR "Hard-clipping still remaining: $count_hard_remaining\n";
