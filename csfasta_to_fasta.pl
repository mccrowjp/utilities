#!/usr/bin/env perl
use strict;

my %csmap = ('A0'=>'A', 'A1'=>'C', 'A2'=>'G', 'A3'=>'T',
	     'C0'=>'C', 'C1'=>'A', 'C2'=>'T', 'C3'=>'G',
	     'G0'=>'G', 'G1'=>'T', 'G2'=>'A', 'G3'=>'C',
	     'T0'=>'T', 'T1'=>'G', 'T2'=>'C', 'T3'=>'A');

sub cs2nt {
    my $csstr = shift;
    my @cslist = split(//, $csstr);
    my $lastnt = $cslist[0];
    my $ntstr = "";
    for(my $i=1; $i<scalar(@cslist); $i++) {
	my $thisnt = $csmap{$lastnt.$cslist[$i]};
	$ntstr .= $thisnt;
	$lastnt = $thisnt;
    }
    return $ntstr;
}

###

my $infa = shift;

unless($infa) {
    die "Usage: $0 [CS-FASTA file]\nConverts color space FASTA to nucleotide FASTA\n";
}

open(IN, $infa) or die "Unable to open file $infa\n";
my $seq = "";
while(<IN>) {
    chomp;
    if(/>/) {
	if(length($seq) > 0) {
	    $seq =~ s/[\s\t\r\n]//g;
	    print cs2nt($seq)."\n";
	}
	$seq = "";
	print $_."\n";
    } else {
	$seq .= $_;
    }
}
if(length($seq) > 0) {
    $seq =~ s/[\s\t\r\n]//g;
    print cs2nt($seq)."\n";
}
close(IN);
