#!/usr/bin/env perl
use strict;

my @filelist = @ARGV;

unless(scalar(@filelist) > 0) {
    die "Usage: $0 [file(s)...]\n";
}

foreach my $file (@filelist) {
    my $str = "";

    if(open(IN, $file)) {
        while(<IN>) {
            $str .= $_;
        }
        close(IN);

        $str =~ s/\n\r/\n/g;
        $str =~ s/\r\n/\n/g;
        $str =~ s/\r/\n/g;
        chomp $str;
        $str .= "\n";

        if(open(OUT, ">$file")) {
            print OUT $str;
            close(OUT);
        } else {
            print STDERR "Unable to write to file $file\n";
        }
        
    } else {
         print STDERR "Unable to open file $file\n";
    }
}
