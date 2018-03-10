#!/usr/bin/env perl
use strict;
use Getopt::Long;

###

sub min {
    my $retval = shift;
    foreach my $v (@_) {
	if($v < $retval) {
	    $retval = $v;
	}
    }
    return $retval;
}

sub max {
    my $retval = shift;
    foreach my $v (@_) {
	if($v > $retval) {
	    $retval = $v;
	}
    }
    return $retval;
}

###

my %idlen;

my $gff_source = "m8_to_gff";
my $gff_feature = "gene";
my $fafile;
my $ethresh;

GetOptions ("q=s" => \$fafile,
            "e=f" => \$ethresh,
            "s=s" => \$gff_source,
            "f=s" => \$gff_feature);

my $m8file = shift;

my $help = <<HELP;
Usage: $0 (options) [Blast m8 file (- for STDIN)]

  -q text  : Query FASTA (to determine full lengths)
             [Default: 5'-extension only]

  -e real  : E-value threshold
  
  -s text  : Source to list (project, database, or program name)
             [Default: fasta_to_gff]

  -f text  : Feature type (typical values: gene, transcript, CDS, exon)
             [Default: gene]

HELP

unless($m8file) {
    die $help;
}

if($fafile =~ /\.gz$/) {
    open(IN, "gunzip -c $fafile 2>/dev/null |");
} else {
    open(IN, $fafile) or die "Unable to open file $fafile\n";
}
print STDERR "reading $fafile\n";

my $id;
while(<IN>) {
    chomp;
    if(/^>/) {
        ($id) = split(/\s/, $');
    } else {
        s/\s//g;
        if(defined($id)) {
            $idlen{$id} += length($_);
        }
    }
}
close(IN);


if($m8file eq '-') {
    open(IN, "<&=STDIN") or die "Unable to read from STDIN\n";
} elsif($m8file =~ /.gz$/) {
    open(IN, "gunzip -c $m8file 2>/dev/null |");
} else {
    open(IN, $m8file) or die "Unable to open file $m8file\n";
}
print STDERR "reading $m8file\n";

while(<IN>) {
    chomp;
    my ($qid, $sid, $pid, $len, $mm, $go, $qs, $qe, $ss, $se, $e, $bs) = split(/\t/);
    if($e <= $ethresh || !defined($ethresh)) {
        my $gff_s = min($ss, $se);
        my $gff_e = max($se, $ss);
        my $left = ($qs - 1);
        my $right = ($idlen{$qid} - $qe);
    
        if($left > 0) {
            $gff_s -= $left;
        }
        if($right > 0) {
            $gff_e += $right;
        }
        if($gff_s < 1) {
            $gff_s = 1;
        }
    
        print join("\t", ($sid, $gff_source, $gff_feature, $gff_s, $gff_e, ".", ($se >= $ss ? "+" : "-"), ".", $gff_feature."_id ".$qid))."\n";
    }
}
close(IN);
