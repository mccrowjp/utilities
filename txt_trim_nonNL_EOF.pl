#!/usr/bin/env perl
use strict;

my @filelist;

unless(@ARGV > 0) {
    die "Usage: $0 [File(s) ...]\n";
}

foreach my $file (@ARGV) {
    open(IN, $file) or die "Unable to open file $file\n";
    my $chr_first;
    my $chr_last;
    read(IN, $chr_first, 1);
    seek(IN, -1, 2);
    read(IN, $chr_last, 1);
    close(IN);
    
    if($chr_last eq "\n") {
    } else {
        if(length($chr_first)+length($chr_last) > 0) {
            push(@filelist, $file);
        } else {
            # empty file
        }
    }
}

if(scalar(@filelist) > 0) {
    print STDERR "Trimming ".scalar(@filelist)." of ".scalar(@ARGV)." file(s):\n";

    foreach my $file (@filelist) {
        my $file2 = $file."~";
        if(system("mv $file $file2") == 0) {
            open(OUT, ">".$file) or die "Unable to write to file $file\n";
            open(IN, $file2) or die "Unable to read file $file2\n";
            print STDERR $file."\n";
        
            while(<IN>) {
                if(/\n$/) {
                    print OUT $_;
                }
            }
            close(IN);
            close(OUT);
            system("rm $file2");
        
        } else {
            die "Unable to write temporary file $file2\n";
        }
    }
    
    print STDERR "Done.\n";
}
