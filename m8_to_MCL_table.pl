#!/usr/bin/env perl
use strict;

use constant MEM_PER_IDS_ESTIMATE => 0.04187;   # Gigabytes per thousand IDs

my $maxidspercycle = 300000;

my $blastfile = shift;
unless($blastfile) {
    die "Usage: $0 [m8 blast table]\n";
}

my %selfbs;
my %pairbs;
my %otherpairs;
my %done;

my $paircount = 0;
my $lines = 0;

printf STDERR "Estimated memory usage: %.1f G\n", $maxidspercycle * MEM_PER_IDS_ESTIMATE / 1000;

if($blastfile =~ /\.gz$/) {
    open(IN, "gunzip -c $blastfile 2>/dev/null |");
} elsif($blastfile =~ /\.bz2$/) {
    open(IN, "bzip2 -dc $blastfile 2>/dev/null |");
} else {
    open(IN, $blastfile) or die "Unable to open file $blastfile\n";
}
print STDERR "Reading m8 blast file: $blastfile\n";
while(<IN>) {
    chomp;
    unless(/^\#/) {
	$lines++;
        my @m8 = split(/\t/);
        my $id1 = $m8[0];
        my $id2 = $m8[1];
	my $bs = $m8[11];

	if($id1 eq $id2) {
            if($bs > $selfbs{$id1}) {
                $selfbs{$id1} = $bs;
            }
        }
    }
}

my $count_ids = scalar(keys %selfbs);
my $count_cycles = int($count_ids / $maxidspercycle) + 1;
my $idspercycle = int($count_ids / $count_cycles) + 1;

print STDERR "IDs: $count_ids\n";
if($count_cycles > 1) {
    print STDERR "Splitting into $count_cycles cycles, $idspercycle per cycle\n";
}

my $curcyclecount = 0;
my $curcyclenum = 0;
my %curcycleid;

foreach my $id (sort keys %selfbs) {
    $curcycleid{$id} = 1;
    $curcyclecount++;
    if($curcyclecount >= $idspercycle) {
	runcycle();
    }
}
runcycle();

print STDERR "done.\n";


###

sub runcycle {
    if(scalar(keys %curcycleid) > 0) {

	$curcyclenum++;
	if($count_cycles > 1) {
	    print STDERR "Cycle: $curcyclenum of $count_cycles\n";
	}
	
	if($blastfile =~ /\.gz$/) {
	    open(IN, "gunzip -c $blastfile 2>/dev/null |");
	} elsif($blastfile =~ /\.bz2$/) {
	    open(IN, "bzip2 -dc $blastfile 2>/dev/null |");
	} else {
	    open(IN, $blastfile) or die "Unable to open file $blastfile\n";
	}
	while(<IN>) {
	    chomp;
	    unless(/^\#/) {
		my @m8 = split(/\t/);
		my $id1 = $m8[0];
		my $id2 = $m8[1];
		my $bs = $m8[11];
		
		unless($id1 eq $id2) {
		    if($curcycleid{$id1}) {
			unless(exists($pairbs{$id1}{$id2})) {
			    push(@{$otherpairs{$id1}}, $id2);
			    $paircount+=0.5;
			}
			if($bs > $pairbs{$id1}{$id2}) {
			    $pairbs{$id1}{$id2} = $bs;
			}
		    }
		}
	    }
	}
	close(IN);
	
	foreach my $id1 (sort keys %curcycleid) {
	    foreach my $id2 (@{$otherpairs{$id1}}) {
		unless($done{$id2}) {
		    my $s1 = $selfbs{$id1} > 0 ? $pairbs{$id1}{$id2} / $selfbs{$id1} : 0;
		    my $s2 = $selfbs{$id2} > 0 ? $pairbs{$id2}{$id1} / $selfbs{$id2} : 0;
		    my $s = sprintf "%.4f", ($s2>$s1 ? $s2 : $s1);
		    
		    if($s > 1.0) {
			$s = 1;
		    }
		    if($s > 0) {
			print join("\t", ($id1, $id2, $s))."\n";
		    }
		}
	    }
	    $done{$id1} = 1;
	}
	
	%done = ();
	%otherpairs = ();
	%pairbs = ();
	%curcycleid = ();
	$curcyclecount = 0;
    }
}
