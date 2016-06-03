#!/usr/bin/env perl
use strict;
use Getopt::Long;

my $verbose = 0;
my $maxseqs = 100000;

GetOptions ("s=i" => \$maxseqs,
            "v" => \$verbose);

my $help = <<HELP;
FASTQ Check N Quality

Usage: $0 (options) [FASTQ file(s)...]

  -s int  : Maximum number of sequences to count per file (default: 100000)
            Setting -s 0 will count all sequences

  -v      : Verbose output

HELP

my @fqfiles = @ARGV;

unless(scalar(@fqfiles) > 0) {
    die $help;
}

print join("\t", ("file", "sequences_counted", "bases_acgt", "bases_N", "bases_other", "quality_acgt", "quality_N", "quality_other"))."\n";

foreach my $infq (@fqfiles) {
    my %typecount = ();
    my %typequalsum = ();
    my $totalbases = 0;
    
    if($infq =~ /\.gz$/) {
        open(IN, "gunzip -c $infq 2>/dev/null |");
    } else {
        open(IN, $infq) or die "Unable to open file $infq\n";
    }
    
    if($verbose) {
        print STDERR "Reading file: $infq ...\n";
    }
    
    my $rec = 0;
    my $sn = 0;
    my $seq = "";
    do {
        $sn++;
        if(defined($_ = <IN>)) {
            chomp;
            if($sn == 2) {
                $seq = $_;
            } elsif($sn == 4) {
                my @slist = split(//, $seq);
                my @qlist = split(//, $_);
                for(my $i=0; $i<scalar(@qlist); $i++) {
                    my $q = ord($qlist[$i])-33;
                    my $s = $slist[$i];
                    my $type = "";
                    if($s =~ /[nN]/) {
                        $type = "N";
                    } elsif($s =~ /[acgtACGT]/) {
                        $type = "acgt";
                    } else {
                        $type = "other";
                    }
                    $totalbases++;
                    $typecount{$type}++;
                    $typequalsum{$type} += $q;
                }
            }
        }
        if($sn >= 4) {
            $sn = 0;
            $rec++;
        }
    } until(eof IN || $maxseqs == 0 || $rec >= $maxseqs);
    
    print $infq."\t".$rec;
    foreach my $type ("acgt", "N", "other") {
        printf "\t%d (%.3f\%)", $typecount{$type}, 100.0*$typecount{$type}/$totalbases;
    }
    foreach my $type ("acgt", "N", "other") {
        printf "\t%.1f", $typecount{$type} > 0 ? $typequalsum{$type}/$typecount{$type} : 0;
    }
    print "\n";
}
