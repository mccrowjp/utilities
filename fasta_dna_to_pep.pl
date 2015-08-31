#!/usr/bin/env perl
use strict;

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
    
    if(length($seq) > 0) {
        my @nts = split(//, $seq);
        my $c = "";
        for(my $i=0; $i<scalar(@nts); $i++) {
            $c .= $nts[$i];
            if(length($c) == 3) {
                my $aa = codontable($c);
                print $aa;
                $c = "";
            }
        }
        print "\n";
    }
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
        translate($seq);
        print $_."\n";
        $seq = "";
    } else {
        $seq .= $_;
    }
}
close(IN);
translate($seq);
