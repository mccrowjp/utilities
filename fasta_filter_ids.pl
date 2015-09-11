#!/usr/bin/env perl
use strict;

my $idfile = shift;
my $fafile = shift;

my %ids;
my $read;
my %foundids;
my $totalfa = 0;

unless($idfile && $fafile) {
    die "Usage: $0 [id file] [fasta file]\noutput: fasta of only IDs in first column of id_file\n";
}

if($idfile =~ /\.gz$/) {
    open(IN, "gunzip -c $idfile 2>/dev/null |");
} else {
    open(IN, $idfile) or die "Unable to open file $idfile\n";
}
while(<IN>) {
    chomp;
    my ($id) = split(/[\t\s]/);
    $ids{$id} = 1;
}
close(IN);

print STDERR "ID file: IDs = ".scalar(keys %ids)."\n";

if($fafile =~ /\.gz$/) {
    open(IN, "gunzip -c $fafile 2>/dev/null |");
} else {
    open(IN, $fafile) or die "Unable to open file $fafile\n";
}
while(<IN>) {
    if(/^>/) {
        $totalfa++;
        $read = 0;
        my ($id) = split(/[\t\s]/, $');  #');
        if($ids{$id}) {
            $foundids{$id} = 1;
            $read = 1;
        }
    }
    if($read) {
        print $_;
    }
}
close(IN);

print STDERR "Fasta file: total = ".$totalfa.", IDs found = ".scalar(keys %foundids)."\n";
