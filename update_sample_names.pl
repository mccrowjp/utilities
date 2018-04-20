#!/usr/bin/env perl
use strict;

my %newname;
my $count_new = 0;

my ($namefile, @filelist) = @ARGV;

unless($namefile && scalar(@filelist) > 0) {
    die "Usage: $0 [sample names file (new_name old_name)] [files to update...]\n";
}

open(IN, $namefile) or die "Unable to open to file $namefile\n";
while(<IN>) {
    chomp;
    my ($new, $old) = split(/\t/);
    $newname{$old} = $new;
    $count_new++;
}
close(IN);

foreach my $file (@filelist) {
    unless(-e $file) {
        die "File not found: $file\n";
    }
}

foreach my $file (@filelist) {
    my $count_total = 0;
    my $count_updated = 0;
    my $backupfile = $file."~";

    system("cp $file $backupfile");

    open(IN, $backupfile) or die "Unable to open file $backupfile\n";
    open(OUT, ">".$file) or die "Unable to write to file $file\n";

    my $fl = 1;
    while(<IN>) {
        chomp;

        if($fl) {
            my @vals = split(/\t/);
            for(my $i=0; $i<scalar(@vals); $i++) {
                $count_total++;
                unless($i==0) {
                    print OUT "\t";
                }
                if(exists($newname{$vals[$i]})) {
                    print OUT $newname{$vals[$i]};
                    $count_updated++;
                } else {
                    print OUT $vals[$i];
                }
            }
            print OUT "\n";
        } else {
            print OUT $_."\n";
        }
        $fl = 0;
    }

    close(OUT);
    close(IN);
    
    printf STDERR "%s\tcolumns total: %d\tsample names: %d\tupdated: %d\n", $file, $count_total, $count_new, $count_updated;
}
