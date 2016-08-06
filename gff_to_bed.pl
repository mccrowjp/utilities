#!/usr/bin/env perl
use strict;

my %idctg;
my %idstart;
my %idend;

my $infile = shift;
my $key = shift;

unless($infile) {
    die "Usage: $0 [GFF file] ([ID key, default='ID'])\n";
}

unless($key) {
    $key = "ID";
}

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}


my $featnum = 0;

while(<IN>) {
    chomp;
    if(/^\#/) {
        print $_."\n";
    
    } else {
        my ($ctg, $source, $feat, $s, $e, $score, $strand, $frame, $attrstr) = split(/\t/);
        my $found = 0;
        foreach my $att (split(/;/, $attrstr)) {
            if($att =~ /^($key)[\=\s]+(.+)$/) {
                my $id = $2;
                $id =~ s/[\"\']//g;
                
                $idctg{$id} = $ctg;
                
                if(!defined($idstart{$id}) || $s < $idstart{$id}) {
                    $idstart{$id} = $s;
                }
                
                if(!defined($idend{$id}) || $e > $idend{$id}) {
                    $idend{$id} = $e;
                }
                $found = 1;
            }
        }
        if(!$found) {
            $featnum++;
            my $id = 'id_'.$featnum;
            $idctg{$id} = $ctg;
            $idstart{$id} = $s;
            $idend{$id} = $e;
        }
    }
}

foreach my $id (sort {$idctg{$a} cmp $idctg{$b} || $idstart{$a}<=>$idstart{$b}} keys %idctg) {
    print join("\t", ($idctg{$id}, $idstart{$id}, $idend{$id}, $id))."\n";
}
