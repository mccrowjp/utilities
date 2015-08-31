#!/usr/bin/env perl
use strict;

my $count=0;
my $empty_count = 0;
my $filecount=0;

foreach my $file (@ARGV) {
    open(IN, $file) or die "Unable to open file $file\n";
    $filecount++;
    my $chr_first;
    my $chr_last;
    read(IN, $chr_first, 1);
    seek(IN, -1, 2);
    read(IN, $chr_last, 1);
    close(IN);
    
    if($chr_last eq "\n") {
    } else {
        if(length($chr_first)+length($chr_last) > 0) {
            print STDERR $file."\n";
            $count++;
        } else {
            $empty_count++;
        }
    }
}

if($empty_count > 0) {
    print STDERR "Empty files: $empty_count\n";
}

if($count > 0) {
    print STDERR "Total files (".$filecount.") ending without NL: $count\n";
} else {
    print STDERR "All files (".$filecount.") end in NL\n";
}
