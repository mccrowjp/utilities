#!/usr/bin/env perl
use strict;

sub writeout {
    my ($id, $seq) = @_;
    $id =~ s/[\s\t\r\n]//g;
    $seq =~ s/[\s\t\r\n]//g;
    if(length($id) > 0 && length($seq) > 0) {
        print $id."\t".$seq."\n";
    }    
}

###

my $infile = shift;

unless($infile) {
    die "Usage: $0 [FASTA file (.gz)]\n";
}

if($infile eq '-') {
    open(IN, "<&=STDIN") or die "Unable to open STDIN\n";
} elsif($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

my $id;
my $seq;

print "id\tsequence\n";
while(<IN>) {
    chomp;
    if(/^>/) {
        writeout($id, $seq);
        ($id) = split(/[\s\t\r\n]/, $');
        $seq = "";
    } else {
        $seq .= $_;
    }
}
writeout($id, $seq);
