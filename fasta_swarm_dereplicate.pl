#!/usr/bin/env perl
use strict;
use Digest::SHA1 qw(sha1 sha1_hex sha1_base64);

my %seqcount;
my $seq = "";

sub eachseq {
    if(length($seq) > 0) {
        $seq =~ s/[^ACGTacgt]//g;
        $seq =~ tr/ACGT/acgt/;
        $seqcount{$seq}++;
    }
}

###

my $infile = shift;
my $outfile = shift;

unless($infile && $outfile) {
    die "Usage: $0 [input FASTA] [output dereplicated FASTA for SWARM input]\n";
}

if(-e $outfile) {
    die "Output file already exists: $outfile\n";
}

open(IN, $infile) or die "Unable to open file $infile\n";
while(<IN>) {
    chomp;
    if(/^>/) {
        eachseq();
        $seq = "";
    } else {
        $seq .= $_;
    }
}
eachseq();

close(IN);

open(OUT, ">".$outfile) or die "Unable to write to file $outfile\n";

foreach my $seq (sort {$seqcount{$b}<=>$seqcount{$a}} keys %seqcount) {
    printf OUT ">%s_%d\n%s\n", sha1_hex($seq), $seqcount{$seq}, $seq;
}

close(OUT);
