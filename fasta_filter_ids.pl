#!/usr/bin/env perl
use strict;

my ($idfile, @fastalist) = @ARGV;

my %ids;
my %foundids;
my $totalfa = 0;

unless($idfile && scalar(@fastalist) > 0) {
    die "Usage: $0 [id file] [FASTA file(s) ...]\noutput: FASTA of only IDs in first column of id_file\n";
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

foreach my $fafile (@fastalist) {
    if($fafile =~ /\.gz$/) {
        open(IN, "gunzip -c $fafile 2>/dev/null |");
    } else {
        open(IN, $fafile) or die "Unable to open file $fafile\n";
    }
    
    my $read = 0;
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
}

print STDERR "Fasta file(s): IDs = $totalfa\n";
print STDERR "Matching IDs found = ".scalar(keys %foundids)."\n";
