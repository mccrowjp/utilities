#!/usr/bin/env perl
use strict;
use Getopt::Long;

my %aaNs = ('R', 4, 'H', 3, 'N', 2, 'Q', 2, 'K', 2, 'F', 2, 'W', 2, 'Y', 2, 'A', 1, 'D', 1, 'C', 1, 'E', 1, 'G', 1, 'I', 1, 'L', 1, 'M', 1, 'P', 1, 'S', 1, 'T', 1, 'V', 1);
my %aaCs = ('R', 6, 'H', 6, 'N', 4, 'Q', 5, 'K', 6, 'F', 9, 'W', 11, 'Y', 9, 'A', 3, 'D', 4, 'C', 3, 'E', 5, 'G', 2, 'I', 6, 'L', 6, 'M', 5, 'P', 5, 'S', 3, 'T', 4, 'V', 5);

my $countmet = 0;
my $countunknowns = 0;

my $totseqs = 0;

GetOptions ("m" => \$countmet,
            "x" => \$countunknowns);

my $help = <<HELP;
Summarize C/N content of amino acid sequences

Usage: $0 (options) [peptide FASTA file]

  -m  : Count first MET (default: ignore)
  -x  : Count non-amino acid characters (default: ignore)

HELP

my $infile = shift;

unless($infile) {
    die $help;
}

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

my $firstchar;
my $numC = 0;
my $numN = 0;
my $numaa = 0;
my $numseqs = 0;

while(<IN>) {
    if(/^>/) {
        $firstchar = 1;
        $numseqs++;
        
    } else {
        tr/a-z/A-Z/;
        foreach my $aa (split(//)) {
            if($aa =~ /[A-Z]/) {
                
                if((!$countunknowns && $aa =~ /[^ARNDCEQGHILKMFPSTWYV]/) ||
                    (!$countmet && $firstchar && $aa eq 'M')
                    ) {
                        # Skip unknown aa, or first Met of peptide
                
                    } else {
                        $numC += $aaCs{$aa};
                        $numN += $aaNs{$aa};
                        $numaa++;
                    }
                
                $firstchar = 0;
            }
        }
    }
}
close(IN);

print "Sequences         : $numseqs\n";
print "Amino acids       : $numaa\n";
printf "C total (average) : %d (%.1f)\n", $numC, $numC/$numaa;
printf "N total (average) : %d (%.1f)\n", $numN, $numN/$numaa;
printf "C/N ratio         : %.4f\n", $numC/$numN;
