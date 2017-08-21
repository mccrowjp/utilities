#!/usr/bin/env perl
use strict;

my $file1;
my $file2;
my $firstonly = 0;

my $opt = shift;
if($opt eq '-1') {
    $firstonly = 1;
    $file1 = shift;
    $file2 = shift;
} else {
    $file1 = $opt;
    $file2 = shift;
}

my $n1;
my $n2;
my @headercols;
my %ischar;
my %data;
my %ids1;
my %ids2;
my %idsboth;
my @idlist;

my $help = <<HELP;
Usage: $0 (options) [File1] [File2]
    input:  tab delimited tables, with header line, matching on first column
    output: combined table
    options:
       -1 :  keep lines from File1 only (default: no, keep all lines)

HELP

unless($file1 && $file2) {
    die $help;
}

# Find datatype of all columns

my $fl = 1;
if($file1 =~ /\.gz$/) {
    open(IN, "gunzip -c $file1 2>/dev/null |");
} else {
    open(IN, $file1) or die "Unable to open file $file1\n";
}
while(<IN>) {
    chomp;
    my ($id, @rest) = split(/\t/);
    if($fl) {
        $n1 = scalar(@rest);
        @headercols = ($id, @rest);
    } else {
        if($ids1{$id}) {
            die "Duplicate ID in file1: $id\n";
        }
        $ids1{$id}=1;
        push(@idlist, $id);
        
        for(my $i=0; $i<$n1; $i++) {
            unless($ischar{$i}) {
                unless($rest[$i] =~ /^[\-\d\.eE]*$/) {
                    $ischar{$i} = 1;
                }
            }
        }
    }
    $fl = 0;
}
close(IN);

$fl = 1;
if($file2 =~ /\.gz$/) {
    open(IN, "gunzip -c $file2 2>/dev/null |");
} else {
    open(IN, $file2) or die "Unable to open file $file2\n";
}
while(<IN>) {
    chomp;
    my ($id, @rest) = split(/\t/);
    if($fl) {
        $n2 = scalar(@rest);
        push(@headercols, @rest);
    } else {
        if($ids2{$id}) {
            die "Duplicate ID in file2: $id\n";
        }
        $ids2{$id}=1;
        if($ids1{$id}) {
            $idsboth{$id} = 1;
        } else {  # add IDs unique to file2 at the end
            unless($firstonly) {
                push(@idlist, $id);
            }
        }
        for(my $i=0; $i<$n2; $i++) {
            unless($ischar{$i+$n1}) {
                unless($rest[$i] =~ /^[\-\d\.eE]*$/) {
                    $ischar{$i+$n1} = 1;
                }
            }
        }
    }
    $fl = 0;
}
close(IN);

# Read all data from both files

$fl = 1;
open(IN, $file1) or die "Unable to open file $file1\n";
while(<IN>) {
    chomp;
    my ($id, @rest) = split(/\t/);
    unless($fl) {
        for(my $i=0; $i<$n1; $i++) {
            $data{$id}{$i} = $rest[$i];
        }
    }
    $fl = 0;
}
close(IN);

$fl = 1;
open(IN, $file2) or die "Unable to open file $file2\n";
while(<IN>) {
    chomp;
    my ($id, @rest) = split(/\t/);
    unless($fl) {
        if(!$firstonly || $ids1{$id}) {
            for(my $i=0; $i<$n2; $i++) {
                $data{$id}{$i+$n1} = $rest[$i];
            }
        }
    }
    $fl = 0;
}
close(IN);

# Write out merged table

print join("\t", @headercols)."\n";
foreach my $id (@idlist) {
    print $id;
    for(my $i=0; $i<$n1+$n2; $i++) {
        print "\t";
        if(exists($data{$id}{$i})) {
            print $data{$id}{$i};
        } else {
            unless($ischar{$i}) {
                print "0";
            }
        }
    }
    print "\n";
}

print STDERR "File 1: ".scalar(keys %ids1)."\n";
print STDERR "File 2: ".scalar(keys %ids2)."\n";
print STDERR "Both  : ".scalar(keys %idsboth)."\n";
