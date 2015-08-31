#!/usr/bin/env perl
use strict;

sub revcomp {
    my $seq = shift;
    $seq =~ tr/acgtACGT/tgcaTGCA/;
    return reverse($seq);
}

sub codontable {
    my $codon = shift;
    $codon =~ tr/a-z/A-Z/;
    my ($c1, $c2, $c3) = split(//, $codon);
    
    my $aa = ($c1 eq 'T'?($c2 eq 'T'?($c3 eq 'T'||$c3 eq 'C'?'F':'L'):($c2 eq 'C'?'S':($c2 eq 'A'?($c3 eq 'T'||$c3 eq 'C'?'Y':'*'):($c2 eq 'G'?($c3 eq 'T'||$c3 eq 'C'?'C':($c3 eq 'A'?'*':'W')):'X')))):
        ($c1 eq 'C'?($c2 eq 'T'?'L':($c2 eq 'C'?'P':($c2 eq 'A'?($c3 eq 'T'||$c3 eq 'C'?'H':'Q'):($c2 eq 'G'?'R':'X')))):
        ($c1 eq 'A'?($c2 eq 'T'?($c3 eq 'G'?'M':'I'):($c2 eq 'C'?'T':($c2 eq 'A'?($c3 eq 'T'||$c3 eq 'C'?'N':'K'):($c2 eq 'G'?($c3 eq 'T'||$c3 eq 'C'?'S':'R'):'X')))):
        ($c1 eq 'G'?($c2 eq 'T'?'V':($c2 eq 'C'?'A':($c2 eq 'A'?($c3 eq 'T'||$c3 eq 'C'?'D':'E'):($c2 eq 'G'?'G':'X')))):'X'))));
    return $aa;
}

sub translate {
    my $seq = shift;
    $seq =~ s/ //g;
    
    my $retseq = "";
    
    if(length($seq) > 0) {
        my @nts = split(//, $seq);
        my $c = "";
        for(my $i=0; $i<scalar(@nts); $i++) {
            $c .= $nts[$i];
            if(length($c) == 3) {
                my $aa = codontable($c);
                $retseq .= $aa;
                $c = "";
            }
        }
    }
    return $retseq;
}

sub printbest {
    my $seq0 = shift;
    my $seqrc;
    my $bestts = translate($seq0);
    my $bestnstp = scalar(split(/\*/, $bestts))-1;
    my $frame = 1;
    
    while($bestnstp > 0 && $frame < 6) {
        $frame++;
        my $s = "";
        if($frame == 2) {
            $s = substr($seq0, 1);
        } elsif($frame == 3) {
            $s = substr($seq0, 2);
        } elsif($frame == 4) {
            $seqrc = revcomp($seq0);
            $s = $seqrc;
        } elsif($frame == 5) {
            $s = substr($seqrc, 1);
        } elsif($frame == 6) {
            $s = substr($seqrc, 2);
        } else {
            last;
        }
        my $ts = translate($s);
        my $nstp = scalar(split(/\*/, $ts))-1;
        if($nstp < $bestnstp) {
            $bestts = $ts;
        }
    }
    
    print $bestts."\n";
}

###

my $fafile = shift;

unless($fafile) {
    die "Usage: $0 [nucleotide FASTA]\n  output: peptide FASTA\n";
}

my $seq = "";
open(IN, $fafile) or die "Unable to open file $fafile\n";
while(<IN>) {
    chomp;
    if(/^>/) {
        printbest($seq);
        print $_."\n";
        $seq = "";
    } else {
        $seq .= $_;
    }
}
close(IN);
printbest($seq);
