#!/usr/bin/env perl
use strict;

my $vcffile = shift;

unless($vcffile) {
    die "Usage: $0 [VCF file]\n";
}

my %chrsnps;
my %chrdepth;
my %chrvar;

if($vcffile =~ /\.gz$/) {
    open(IN, "gunzip -c $vcffile 2>/dev/null |");
} else {
    open(IN, $vcffile) or die "Unable to open file $vcffile\n";
}

while(<IN>) {
    chomp;
    unless(/^\#/) {
	my ($chr, $pos, $id, $ref, $alt, $qual, $filt, $info) = split(/\t/);
	my @infolist = split(/;/, $info);
	my $depth = 0;
	my $refdepth = 0;
	my $vardepth = 0;
	foreach my $kv (@infolist) {
	    my ($key, $val) = split(/=/, $kv);
	    if($key eq 'DP') {
		$depth = $val;
	    }
	    if($key eq 'DP4') {
		my ($r1, $r2, $v1, $v2) = split(/,/, $val);
		$refdepth = $r1 + $r2;
		$vardepth = $v1 + $v2;
	    }
	}
	# If DP was not specified, used DP4
	if($depth < 1) {
	    $depth = $refdepth + $vardepth;
	}
	$chrsnps{$chr}++;
	$chrdepth{$chr} += $depth;
	$chrvar{$chr} += $vardepth;
    }
}

print join("\t", ('id','snps','total_depth','total_variant_depth','ave_snp_depth','ave_variant_freq'))."\n";
foreach my $chr (sort keys %chrsnps) {
    printf join("\t", ('%s','%d','%d','%d','%.1f','%.1f'))."\n", $chr, $chrsnps{$chr}, $chrdepth{$chr}, $chrvar{$chr}, $chrdepth{$chr} / $chrsnps{$chr}, $chrdepth{$chr}>0 ? $chrvar{$chr} / $chrdepth{$chr} : 0;
}
