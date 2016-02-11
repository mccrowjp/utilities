#!/usr/bin/env perl
use strict;

my @covfiles = @ARGV;
my %alllibs;
my %ctglen;
my %ctglibreads;
my %ctglibcov;

unless(scalar(@covfiles) > 1) {
    die "Usage: $0 [BAM coverage summary files...]\n";
}

foreach my $file (@covfiles) {
    my $lib = $file;
    $lib =~ s/.+\///g;
    $lib =~ s/\.coverage\.txt$//;
    $alllibs{$lib} = 1;
    
    open(IN, $file) or die "Unable to open file $file\n";
    my $fl = 1;
    while(<IN>) {
	chomp;
	if($fl) {
	    unless($_ eq join("\t", ('id','length','reads','ave_coverage'))) {
		die "Unrecognized format for BAM coverage summary file: $file\n";
	    }
	    
	} else {
	    my ($id, $len, $reads, $cov) = split(/\t/);
	    
	    if(length($len) > 0) {
		if(!exists($ctglen{$id}) || $len > $ctglen{$id}) {
		    $ctglen{$id} = $len;
		}
	    }

	    $ctglibreads{$id}{$lib} = $reads;
	    $ctglibcov{$id}{$lib} = $cov;
	    
	}
	$fl = 0;
    }
    close(IN);
}

my @liblist = sort keys %alllibs;

print "id\tlength";
foreach my $lib (@liblist) {
    print "\treads_".$lib;
}
foreach my $lib (@liblist) {
    print "\tcov_".$lib;
}
print "\n";

foreach my $id (sort keys %ctglibreads) {
    printf "%s\t%d", $id, $ctglen{$id};
    foreach my $lib (@liblist) {
	print "\t".$ctglibreads{$id}{$lib};
    }
    foreach my $lib (@liblist) {
	print "\t".$ctglibcov{$id}{$lib};
    }
    print "\n";    
}
