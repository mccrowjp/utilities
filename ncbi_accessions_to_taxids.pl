#!/usr/bin/env perl
use strict;

# Download files: ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_*

my @ncbifiles = ("nucl_gb.accession2taxid.gz", "nucl_est.accession2taxid.gz", "nucl_gss.accession2taxid.gz", "nucl_wgs.accession2taxid.gz");
my $infile = shift;

my %allids;

unless($infile) {
    die "Usage: $0 [File listing NCBI accession numbers]\n";
}

open(IN, $infile) or die "Unable to open file $infile\n";
while(<IN>) {
    chomp;
    my ($id) = split(/\s/);
    $id =~ s/\.\d+$//;
    $allids{$id} = 1;
}
close(IN);

my $n = scalar(keys %allids);
my %found;

foreach my $file (@ncbifiles) {
    if(scalar(keys %found) < $n) {
        open(IN, "gunzip -c $file 2>/dev/null |");

        my $fl = 1;
        while(<IN>) {
            chomp;
            unless($fl) {
                my ($acc, $accv, $taxid, $gi) = split(/\t/);
                if($allids{$acc} && !$found{$acc}) {
                    $found{$acc} = 1;
                    print $acc."\t".$taxid."\n";
                }
            }
            $fl = 0;
        }
        close(IN);
    }    
}
