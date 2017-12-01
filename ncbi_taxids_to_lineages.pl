#!/usr/bin/env perl
use strict;

# Download and extract from: ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

my $namesfile = "names.dmp";
my $nodesfile = "nodes.dmp";

my $infile = shift;

my %allids;
my %taxname;
my %nodeparent;

unless($infile) {
    die "Usage: $0 [File listing NCBI taxon IDs]\n";
}

open(IN, $infile) or die "Unable to open file $infile\n";
print STDERR "reading $infile\n";

while(<IN>) {
    chomp;
    my ($id) = split(/\s/);
    $id =~ s/\.\d+$//;
    $allids{$id} = 1;
}
close(IN);

open(IN, $namesfile) or die "Unable to open file $namesfile\n";
print STDERR "reading $namesfile\n";

while(<IN>) {
    chomp;
    my ($taxid, $p1, $name, $p2, $uniqname, $p3, $class) = split(/\t/);
    if($class eq "scientific name") {
        $taxname{$taxid} = $name;
    }
}
close(IN);

open(IN, $nodesfile) or die "Unable to open file $nodesfile\n";
print STDERR "reading $nodesfile\n";

while(<IN>) {
    chomp;
    my ($taxid, $p1, $parentid) = split(/\t/);
    $nodeparent{$taxid} = $parentid;
}
close(IN);

print STDERR "printing lineages\n";
foreach my $id (sort keys %allids) {
    if($taxname{$id}) {
        my @lineagelist = ($taxname{$id});
        my $t = $id;
        while($t > 1) {
            if(exists($nodeparent{$t}) && $t != $nodeparent{$t}) {
                $t = $nodeparent{$t};
                if(length($taxname{$t}) > 0) {
                    unshift(@lineagelist, $taxname{$t});
                }
            } else {
                $t = 0;
            }
        }

        # remove root;cellular organisms from taxonomy string if present
        if($lineagelist[0] eq 'root') {
            shift(@lineagelist);
        }
        if($lineagelist[0] eq 'cellular organisms') {
            shift(@lineagelist);
        }

        if(scalar(@lineagelist) > 0) {
            print $id."\t".join(";", @lineagelist)."\n";
        }
    }
}
