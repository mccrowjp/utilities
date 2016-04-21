#!/usr/bin/env perl
#
# Calculates RPKMs from the output of featureCounts from subread package ( http://subread.sourceforge.net )
#

use strict;

my $incounts = shift;

unless($incounts) {
    die "Usage: $0 [FeatureCounts output table]\n";
}

my %idlen;
my %idhead;
my %idlibcount;
my %libtotal;
my @headnames;
my @libnames;
	
open(IN, $incounts) or die "Unable to open file $incounts\n";
my $fl = 1;
while(<IN>) {
    chomp;
    unless(/^\#/) {
        my ($id, $chr, $s, $e, $strand, $len, @counts) = split(/\t/);
        if($fl) {
            unless($id eq 'Geneid') {
                die "Unrecognized featureCounts table format\n";
            }
            @headnames = ($id, $chr, $s, $e, $strand, $len);
            @libnames = @counts;
            
        } else {
            $idhead{$id} = join("\t", ($id, $chr, $s, $e, $strand, $len));
            $idlen{$id} = $len;
            for(my $i=0; $i<scalar(@counts); $i++) {
                $idlibcount{$id}{$i} += $counts[$i];
                $libtotal{$i} += $counts[$i];
            }
        }
        $fl = 0;
    }
}
close(IN);

print join("\t", (@headnames, @libnames))."\n";

foreach my $id (sort keys %idlen) {
    print $idhead{$id};
    for(my $i=0; $i<scalar(@libnames); $i++) {
        if($libtotal{$i} * $idlen{$id} > 0) {
            printf "\t%.2f", (10**9 * $idlibcount{$id}{$i}) / ($libtotal{$i} * $idlen{$id});
        } else {
            print "\t0";
        }
    }
    print "\n";
}
