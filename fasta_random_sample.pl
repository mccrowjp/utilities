#!/usr/bin/env perl
use strict;
use List::Util qw(shuffle);

# 
# Random sample of fasta sequences without replacement
# 

my $fafile = shift;
my $minseqlen = shift;
my $sampsize = shift;
my $exfile = shift;

my %exseq;
my %seqlen;
my %pick;

unless(length($fafile) > 0 && $minseqlen > 0 && $sampsize > 0) {
    die "Usage: $0 [Fasta file] [Min sequence length] [Sample size] ([Fasta of sequences to exclude])\n";
}

print STDERR "FASTA file : $fafile\n";
print STDERR "Min seq len: $minseqlen\n";
print STDERR "Sample size: $sampsize\n";

if(length($exfile) > 0) {
    if($exfile =~ /\.gz$/) {
        open(IN, "gunzip -c $exfile 2>/dev/null |");
    } else {
        open(IN, $exfile) or die "Unable to open file $exfile\n";
    }
    print STDERR "Excluding  : $exfile\n";
    
    while(<IN>) {
        chomp;
        if(/^>(.+)$/) {
            $exseq{$1} = 1;
        }
    }
    close(IN);
}

my $seq;
if($fafile =~ /\.gz$/) {
    open(IN, "gunzip -c $fafile 2>/dev/null |");
} else {
    open(IN, $fafile) or die "Unable to open file $fafile\n";
}
while(<IN>) {
    chomp;
    if(/^>/) {
        $seq = "";
        if(/^>(.+)$/) {
            $seq = $1;
        }
    } else {
        my $str = $_;
        $str =~ s/[^A-Za-z]//g;
        $seqlen{$seq} += length($str);
    }
}
close(IN);

my @randseq = shuffle(keys %seqlen);
my $i=0;
my $l=0;
while($i<scalar(@randseq) && $l<$sampsize) {
    my $seq = $randseq[$i];
	if($seqlen{$seq} >= $minseqlen && !$exseq{$seq}) {
        $pick{$seq}=1;
	    $l++;
	}
	$i++;
}

$seq = "";
if($fafile =~ /\.gz$/) {
    open(IN, "gunzip -c $fafile 2>/dev/null |");
} else {
    open(IN, $fafile) or die "Unable to open file $fafile\n";
}
while(<IN>) {
    chomp;
    if(/^>/) {
        $seq = "";
        if(/^>(.+)$/) {
            $seq = $1;
        }
    } 
    if($pick{$seq}) {
        print $_."\n";
    }
}
close(IN);   
