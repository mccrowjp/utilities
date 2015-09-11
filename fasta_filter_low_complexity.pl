#!/usr/bin/env perl
use strict;

my %keepid;
my $infa = shift;
my $maxlcfrac = shift;

sub evalseq {
    my ($id, $seq) = @_;
    if(length($id) > 0 && length($seq) > 0) {
        $seq =~ s/[\s\t\r\n]//g;
        my $fulllen = length($seq);
        $seq =~ s/[ACGTacgt]//g;
        my $badlen = length($seq);
        
        if($badlen / $fulllen < $maxlcfrac) {
            $keepid{$id} = 1;
        }
    }
}

###

unless(length($maxlcfrac) > 0) {
    $maxlcfrac = 0.5;  # Maximum low complexity sequence proportion allowed
}

unless($infa) {
    die "Usage: $0 [Nucleotide FASTA file] ([Max. Low Complexity Proportion, default: 0.5])\n";
}

unless(-e $infa) {
    die "File not found: $infa\n";
}

open(DUST, "dust $infa 2>/dev/null |");
my $id = "";
my $seq = "";
while(<DUST>) {
    chomp;
    if(/^>/) {
        evalseq($id, $seq);
        $id = $_;
        $seq = "";
    } else {
        $seq .= $_;
    }
}
evalseq($id, $seq);

my $write = 0;
my $count_all = 0;
my $count_skip = 0;
my $count_new = 0;
open(IN, $infa) or die "Unable to open file $infa\n";
while(<IN>) {
    chomp;
    if(/^>/) {
        $count_all++;
        if($keepid{$_}) {
            $write = 1;
            $count_new++;
        } else {
            $write = 0;
            $count_skip++;
        }
    }
    if($write) {
        print $_."\n";
    }
}

print STDERR "Sequences before: $count_all, skipped: $count_skip, after: $count_new\n";
