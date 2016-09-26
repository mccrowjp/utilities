#!/usr/bin/env perl
use strict;

my $fafile = shift;
my $gfffile = shift;

my %ctglen;
my %featdat;
my %maxctgend;
my %ctgsum;
my $totlen = 0;
my $totsum = 0;

unless($fafile && $gfffile) {
    die "Usage: $0 [FASTA file] [GFF file]\n";
}

if($fafile =~ /\.gz$/) {
    open(IN, "gunzip -c $fafile 2>/dev/null |");
} else {
    open(IN, $fafile) or die "Unable to open file $fafile\n";
}

my $ctg;
while(<IN>) {
    chomp;
    if(/^>/) {
        ($ctg) = split(/[\s\t\r\n]/, $');  #');
    } else {
        s/[\s\t\r\n]//g;
        $ctglen{$ctg} += length($_);
    }
}
close(IN);

if($gfffile =~ /\.gz$/) {
    open(IN, "gunzip -c $gfffile 2>/dev/null |");
} else {
    open(IN, $gfffile) or die "Unable to open file $gfffile\n";
}

my $lastfeat = 0;
while(<IN>) {
    chomp;
    unless(/^\#/) {
        my ($ctg, $source, $feat, $s, $e, $score, $strand, $frame, $attrstr) = split(/\t/);
        $lastfeat++;
        $featdat{$lastfeat}{'ctg'} = $ctg;
        $featdat{$lastfeat}{'feat'} = $feat;
        $featdat{$lastfeat}{'s'} = $s;
        $featdat{$lastfeat}{'e'} = $e;
    }
}
close(IN);

print join("\t", ('contig','total_length','gff_length','percent_covered'))."\n";

foreach my $key (sort {$featdat{$a}{'ctg'} cmp $featdat{$b}{'ctg'} ||
                        $featdat{$a}{'s'}<=>$featdat{$b}{'s'}} keys %featdat) {
                        
    my $ctg = $featdat{$key}{'ctg'};
    my $s = $featdat{$key}{'s'};
    my $e = $featdat{$key}{'e'};
                            
    if($s <= $maxctgend{$ctg}) {
        $s = $maxctgend{$ctg} + 1;
    }
    if($e > $s) {
        $ctgsum{$ctg} += $e - $s + 1;
        $totsum += $e - $s + 1;
    }
    if($e > $maxctgend{$ctg}) {
        $maxctgend{$ctg} = $e;
    }
}

foreach my $ctg (sort keys %ctglen) {
    if($ctglen{$ctg} > 0) {
        $totlen += $ctglen{$ctg};
        printf "%s\t%d\t%d\t%.1f\n", $ctg, $ctglen{$ctg}, $ctgsum{$ctg}, 100.0*$ctgsum{$ctg}/$ctglen{$ctg};
    }
}
printf "%s\t%d\t%d\t%.1f\n", "Total", $totlen, $totsum, 100.0*$totsum/$totlen;
