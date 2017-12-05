#!/usr/bin/env perl
use strict;

my $pi = 4 * atan2(1, 1);

sub acos {
	my $rad = shift;
	return atan2(sqrt(1 - $rad**2), $rad);
}

sub deg2rad {
	my $deg = shift;
	return ($deg * $pi / 180);
}

sub rad2deg {
	my $rad = shift;
	return ($rad * 180 / $pi);
}

sub distance {
    # distance in statue miles, north latitude and east longitude are positive
    my ($lat1, $lon1, $lat2, $lon2) = @_;
	return 69.09 * rad2deg(acos(sin(deg2rad($lat1)) * sin(deg2rad($lat2)) + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($lon1-$lon2))));
}

###

my @head2;
my %latlondata2;
my $ncol1;

my ($file1, $latcol1, $loncol1, $file2, $latcol2, $loncol2) = @ARGV; 

my $help = <<HELP;
Usage: $0 [File 1] [Lat column 1] [Lon column 1] [File 2] [Lat column 2] [Lon column 2]
    input:  tab delimited tables, with header lines, corresponding lat/lon column numbers
    output: table from file 1, distance, and data from file 2 of closest station

HELP

unless(scalar(@ARGV) == 6) {
    die $help;
}

my $fl = 1;
if($file2 =~ /\.gz$/) {
    open(IN, "gunzip -c $file2 2>/dev/null |");
} else {
    open(IN, $file2) or die "Unable to open file $file2\n";
}
while(<IN>) {
    chomp;
    my @cols = split(/\t/);
    if($fl) {
        @head2 = @cols;
        
    } else {
        my $lat2 = $cols[$latcol2-1];
        my $lon2 = $cols[$loncol2-1];
        $latlondata2{$lat2."\t".$lon2} = $_;
    }
    $fl = 0;
}
close(IN);

$fl = 1;
if($file1 =~ /\.gz$/) {
    open(IN, "gunzip -c $file1 2>/dev/null |");
} else {
    open(IN, $file1) or die "Unable to open file $file1\n";
}
while(<IN>) {
    chomp;
    my @cols = split(/\t/);
    if($fl) {
        $ncol1 = scalar(@cols);
        print join("\t", (@cols, 'distance_to_closest_station', @head2))."\n";
        
    } else {
        my $lat1 = $cols[$latcol1-1];
        my $lon1 = $cols[$loncol1-1];
        my $closestdist;
        my $closestlatlon;
        
        foreach my $latlon2 (keys %latlondata2) {
            my ($lat2, $lon2) = split(/\t/, $latlon2);
            my $d = distance($lat1, $lon1, $lat2, $lon2);
            if(!defined($closestdist) || $d < $closestdist) {
                $closestdist = $d;
                $closestlatlon = $latlon2;
            }
        }
        
        # Ensures proper column number for file 1 data
        my @cols1list = ();
        for(my $i=0; $i<$ncol1; $i++) {
            push(@cols1list, $cols[$i]);
        }
        
        print join("\t", (@cols1list, $closestdist, $latlondata2{$closestlatlon}))."\n";
    }
    $fl = 0;
}
close(IN);
