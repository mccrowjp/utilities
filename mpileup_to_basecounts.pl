#!/usr/bin/env perl
use strict;

my %posdel;

my $infile = shift;

unless($infile) {
    die "Usage: $0 [mpileup file]\n";
}

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

print join("\t", ("id", "pos", "refbase", "total", "match", "A", "C", "G", "T", "N", "insert", "deletion"))."\n";

while(<IN>) {
    chomp;
    my ($id, $pos, $refbase, $totcount, $readbases) = split(/\t/);
    $refbase =~ tr/a-z/A-Z/;
    
    $readbases =~ s/\^.//g;
    
    my $count_ins = 0;
    for(my $find = 1; $find; ) {  # inserts
        if($readbases =~ /\+(\d+)/) {
            $readbases = $`.substr($', $1);    #');
            $count_ins++;
        } else {
            $find = 0;
        }
    }
    
    for(my $find = 1; $find; ) {  # deletions
        if($readbases =~ /\-(\d+)/) {
            $readbases = $`.substr($', $1);    #');
            for(my $i=1; $i<=$1; $i++) {
                $posdel{$pos+$i}++;
            }
        } else {
            $find = 0;
        }
    }
    
    my @matches = $readbases =~ /[\.\,]/g;
    my @As = $readbases =~ /[Aa]/g;
    my @Cs = $readbases =~ /[Cc]/g;
    my @Gs = $readbases =~ /[Gg]/g;
    my @Ts = $readbases =~ /[Tt]/g;
    my @Ns = $readbases =~ /[Nn]/g;
    # ignore '*' deletion characters, already accounted for in %posdel
    
    my $count_match = 0 + scalar(@matches);
    my %count_base = ();
    
    $count_base{'A'} = 0 + scalar(@As);
    $count_base{'C'} = 0 + scalar(@Cs);
    $count_base{'G'} = 0 + scalar(@Gs);
    $count_base{'T'} = 0 + scalar(@Ts);
    $count_base{'N'} = 0 + scalar(@Ns);
    $count_base{$refbase} += $count_match;
    
    print join("\t", ($id, $pos, $refbase, $totcount, $count_match,
                    $count_base{'A'}, $count_base{'C'}, $count_base{'G'}, $count_base{'T'}, $count_base{'N'},
                    $count_ins, 0+$posdel{$pos})
            )."\n";
    
}
close(IN);
