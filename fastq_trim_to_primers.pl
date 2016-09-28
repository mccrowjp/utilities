#!/usr/bin/env perl
use strict;

my %seqlen;
my %bestbs;
my %bestqs;
my %bestqe;
my %bestss;
my %bestse;
my %substr_begin;
my %substr_end;

my $minlen = 50;
my $evalthresh = 1;

my $primfa = shift;
my $trimfq = shift;

my $help = <<HELP;
FASTQ trim to primers (in silico PCR) - 05/26/2016

Usage: $0 [FASTA primers] [FASTQ file]

HELP

unless($primfa && $trimfq) {
    die $help;
}

if($primfa =~ /\.gz$/) {
    open(IN, "gunzip -c $primfa 2>/dev/null |");
} else {
    open(IN, $primfa) or die "Unable to open file $primfa\n";
}
print STDERR "reading $primfa\n";

my $id = "";
my $len = 0;
while(<IN>) {
    chomp;
    if(/^>/) {
        if($id) {
            $seqlen{$id} = $len;
        }
        ($id) = split(/[\s\t\r\n]+/, $');  #');
        $len = 0;
    } else {
        s/[^A-Za-z]//g;
        $len += length();
    }
}
if($id) {
    $seqlen{$id} = $len;
}
close(IN);

unless(-e $primfa.".nhr" && -e $primfa.".nin" && -e $primfa.".nsq") {
    system("formatdb -i $primfa -p F");
}

print STDERR "blast $trimfq : $primfa\n";
open(IN, "fastq_to_fasta.pl -i $trimfq -o - | blastall -p blastn -d $primfa -m8 -W7 2>/dev/null |");
while(<IN>) {
    chomp;
    my ($qid, $sid, $pid, $len, $mm, $go, $qs, $qe, $ss, $se, $e, $bs) = split(/\t/);
    if($e <= $evalthresh && $bs > $bestbs{$qid}{$sid}) {
        $bestbs{$qid}{$sid} = $bs;
        $bestqs{$qid}{$sid} = $qs;
        $bestqe{$qid}{$sid} = $qe;
        $bestss{$qid}{$sid} = $ss;
        $bestse{$qid}{$sid} = $se;
    }
}
close(IN);

foreach my $qid (keys %bestbs) {
    if(scalar(keys %{$bestbs{$qid}}) > 1) {
        my $min_s;
        my $max_e;

        foreach my $sid (keys %{$bestbs{$qid}}) {
            my $pos_s = 0;
            my $pos_e = 0;
            
            if($bestss{$qid}{$sid} <= $bestse{$qid}{$sid}) {
                $pos_s = $bestqs{$qid}{$sid} - $bestss{$qid}{$sid} + 1;
                $pos_e = $bestqe{$qid}{$sid} + ($seqlen{$sid} - $bestse{$qid}{$sid});

            } else {  # reverse complement
                $pos_s = $bestqs{$qid}{$sid} - $bestse{$qid}{$sid} + 1;
                $pos_e = $bestqe{$qid}{$sid} + ($seqlen{$sid} - $bestss{$qid}{$sid});
            }
 
            if(!defined($max_e) || $pos_e > $max_e) {
                $max_e = $pos_e;
            }
            if(!defined($min_s) || $pos_s < $min_s) {
                $min_s = $pos_s;
            }
        }
        
        if($max_e - $min_s + 1 >= $minlen) {
            $substr_begin{$qid} = $min_s;
            $substr_end{$qid} = $max_e;
        }
    }
}

print STDERR "trimming: ".scalar(keys %substr_begin)."\n";

if($trimfq =~ /\.gz$/) {
    open(IN, "gunzip -c $trimfq 2>/dev/null |");
} else {
    open(IN, $trimfq) or die "Unable to open file $trimfq\n";
}
print STDERR "reading $trimfq\n";

my $sn = 0;
my $write = 0;
my $line = "";
while($line = <IN>) {
    chomp($line);
    $sn++;
    if($sn > 4) {
        $sn = 1;
    }
    
    if($sn == 1) {
        ($id) = split(/[\s\t\r\n]/, $line);
        $id =~ s/^\@//;
        if(exists($substr_begin{$id}) && exists($substr_end{$id})) {
            $write = 1;
        } else {
            $write = 0;
        }
    }
    if($write) {
        if($sn == 2 || $sn == 4) {
            if($substr_begin{$id} < 1) {
                $substr_begin{$id} = 1
            }
            if($substr_end{$id} > length($line)) {
                $substr_end{$id} = length($line);
            }
            $line = substr($line, $substr_begin{$id} - 1, $substr_end{$id}-$substr_begin{$id}+1);
        }
        print $line."\n";
    }
}
close(IN);

