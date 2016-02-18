#!/usr/bin/env perl
use strict;

my @pidfiles = @ARGV;
my %alllibs;
my %ctglibreads;
my %ctglibpid;

unless(scalar(@pidfiles) > 1) {
    die "Usage: $0 [BAM pid summary files...]\n";
}

foreach my $file (@pidfiles) {
    my $lib = $file;
    $lib =~ s/.+\///g;
    $lib =~ s/\.pid_summary\.txt$//;
    $alllibs{$lib} = 1;
    
    open(IN, $file) or die "Unable to open file $file\n";
    my $fl = 1;
    while(<IN>) {
        chomp;
        if($fl) {
            unless($_ eq join("\t", ('id','reads','ave_identity'))) {
                die "Unrecognized format for BAM pid summary file: $file\n";
            }
            
        } else {
            my ($id, $reads, $pid) = split(/\t/);
            
            $ctglibreads{$id}{$lib} = $reads;
            $ctglibpid{$id}{$lib} = $pid;
            
        }
        $fl = 0;
    }
    close(IN);
}

my @liblist = sort keys %alllibs;

print "id";
foreach my $lib (@liblist) {
    print "\treads_".$lib;
}
foreach my $lib (@liblist) {
    print "\tpid_".$lib;
}
print "\n";

foreach my $id (sort keys %ctglibreads) {
    print $id;
    foreach my $lib (@liblist) {
        print "\t".$ctglibreads{$id}{$lib};
    }
    foreach my $lib (@liblist) {
        print "\t".$ctglibpid{$id}{$lib};
    }
    print "\n";    
}
