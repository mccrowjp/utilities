#!/usr/bin/env perl
use strict;
use Getopt::Long;

my $time_start = localtime();

my $paired = 0;
my $minq = 0;
my $minlen = 0;
my $minave = 33;
my $winsize = 1;
my $outbase;

GetOptions ("a=i" => \$minave,
            "l=i" => \$minlen,
	    "o=s" => \$outbase,
	    "q=i" => \$minq,
	    "w=i" => \$winsize);


my $help = <<HELP;
FASTQ Quality Trimmer - jmccrow 05/29/2013
Assumes format Phred+33.  Give 2 files to interlace paired data.

Usage: $0 (options) [FASTQ file 1] ([FASTQ file 2])

    -a int  : Minimum average quality score in window (default: 33)
    -l int  : Minimum sequence length (default: 0)
    -o file : Output base file name (default: input file 1)
    -q int  : Minimum quality score, bases called N below (default: 0)
    -w int  : Window size for average quality score (default: 1)

HELP

my $infile1 = shift;
my $infile2 = shift;

unless(length($infile1) > 0) {
    die $help;
}

if(length($infile2) > 0) {
    $paired = 1;
}

my $outpt;
if($paired) {
    $outpt = $outbase.".paired_trimmed.fna";
} else {
    $outpt = $outbase.".trimmed.fna";
}
my $outunp1 = $outbase.".unpaired_trimmed_1.fna";
my $outunp2 = $outbase.".unpaired_trimmed_2.fna";
my $outsum = $outbase.".ptsummary.txt";

my $count_tot = 0;
my $count_pt = 0;
my $count_unp1 = 0;
my $count_unp2 = 0;
my %count_bases;
my %count_bases_q;

if($infile1 =~ /\.gz$/) {
    open(IN1, "gunzip -c $infile1 2>/dev/null |");
} else {
    open(IN1, $infile1) or die "Unable to open file $infile1\n";
}
if($paired) { 
    if($infile2 =~ /\.gz$/) {
	open(IN2, "gunzip -c $infile2 2>/dev/null |");
    } else {
	open(IN2, $infile2) or die "Unable to open file $infile2\n";
    }
}

open(OUTPT, ">".$outpt) or die "Unable to write to file $outpt\n";
if($paired) {
    open(OUTUNP1, ">".$outunp1) or die "Unable to write to file $outunp1\n";
    open(OUTUNP2, ">".$outunp2) or die "Unable to write to file $outunp2\n";
}

print STDERR $time_start."\n";

print STDERR "Reading FASTQ file(s) ...\n";

my $sn = 0;
my %sfline;
do {
    $sn++;
    if(defined($_ = <IN1>)) {
	chomp;
	$sfline{1}{$sn} = $_;
    }
    if($paired && defined($_ = <IN2>)) {
	chomp;
	$sfline{2}{$sn} = $_;
    }
    if($sn >= 4) {
	my $p1 = conv($sfline{1}{1}, $sfline{1}{2}, $sfline{1}{3}, $sfline{1}{4}, 1);
	$count_tot++;

	if($paired) { 
	    my $p2 = conv($sfline{2}{1}, $sfline{2}{2}, $sfline{2}{3}, $sfline{2}{4}, 2);
	    $count_tot++;

	    if(length($p1) > 0 && length($p2) > 0) {
		print OUTPT $p1.$p2;
		$count_pt+=2;
	    } else {
		if(length($p1) > 0) {
		    print OUTUNP1 $p1;
		    $count_unp1++;
		}
		if(length($p2) > 0) {
		    print OUTUNP2 $p2;
		    $count_unp2++;
		}
	    }
	} else {
	    if(length($p1) > 0) {
		print OUTPT $p1;
		$count_pt++;
	    }
	}

	%sfline = ();
	$sn = 0;
    }
} until(eof IN1 && (!$paired || eof IN2));

close(OUTPT);
if($paired) {
    close(OUTUNP1);
    close(OUTUNP2);
}

if($count_tot > 0) {
    open(OUTSUM, ">".$outsum) or die "Unable to write to file $outsum\n";
    
    print OUTSUM "Start time       : $time_start\n";
    print OUTSUM "End time         : ".localtime()."\n";
    print OUTSUM "Min quality      : $minq\n";
    print OUTSUM "Min ave. quality : $minave\n";
    print OUTSUM "Window size      : $winsize\n";
    print OUTSUM "Min length       : $minlen\n";
    print OUTSUM "FASTQ file 1     : $infile1\n";
    print OUTSUM "FASTQ file 2     : $infile2\n";
    printf OUTSUM "Paired reads                 : %s\n", ($paired?"yes":"no");
    printf OUTSUM "Total sequences              : %d\n", $count_tot;
    printf OUTSUM "Paired-trimmed sequences     : %d\n", $count_pt;
    printf OUTSUM "Unpaired-trimmed read 1      : %d\n", $count_unp1;
    printf OUTSUM "Unpaired-trimmed read 2      : %d\n", $count_unp2;
    if($paired) {
	printf OUTSUM "Total bases 1 (ave)          : %d (%.1f)\n", $count_bases{1}, 2 * $count_bases{1} / $count_tot;
	printf OUTSUM "Bases quality-trimmed 1 (ave): %d (%.1f)\n", $count_bases_q{1}, 2 * $count_bases_q{1} / $count_tot;
	printf OUTSUM "Total bases 2 (ave)          : %d (%.1f)\n", $count_bases{2}, 2 * $count_bases{2} / $count_tot;
	printf OUTSUM "Bases quality-trimmed 2 (ave): %d (%.1f)\n", $count_bases_q{2}, 2 * $count_bases_q{2} / $count_tot;

    } else {
	printf OUTSUM "Total bases (ave)            : %d (%.1f)\n", $count_bases{1}, $count_bases{1} / $count_tot;
	printf OUTSUM "Bases quality-trimmed (ave)  : %d (%.1f)\n", $count_bases_q{1}, $count_bases_q{1} / $count_tot;
    }
    close(OUTSUM);
}

print STDERR "done.\n";
print STDERR localtime()."\n";


###

sub conv($$$$$) {
    my ($l1, $l2, $l3, $l4, $whichread) = @_;

    my $head = "";
    if($l1 =~ /^\@(.+)$/) {
	$head = $1;
    } else {
	die "Not a valid FASTQ format 1\n";
    }

    my $seq = $l2;

    unless($l3 =~ /^\+/) {
	die "Not a valid FASTQ format 2\n";
    }

    my $qual = $l4;
    unless(length($seq) == length($qual)) {
	die "Not a valid FASTQ format 3\n";
    }

    return qtrim($head, $seq, $qual, $whichread);
}

sub qtrim($$$$) {
    my ($head, $seq, $qual, $whichread) = @_;
    my $minpos = -1;
    my $maxpos = -1;
    my $trimseq = "";

    my @slist = split(//, $seq);
    my @qlist = split(//, $qual);
    my $n = scalar(@qlist);

    my $v_ave_sum = 0;
    my $v_ave_n = 1;

    $count_bases{$whichread} += $n;

    # trim quality
    for(my $i=0; $i<$n; $i++) {
	my $v = ord($qlist[$i])-33;
	
	# keep a running average of quality in the window
	if($i > $winsize-1) {
	    $v_ave_sum += $v - (ord($qlist[$i-$winsize])-33);
	    $v_ave_n = $winsize;
	} else {
	    $v_ave_sum += $v;
	    $v_ave_n = $i+1;
	}
	# if window ave quality is above minave then update trim positions
	if($v_ave_sum / $v_ave_n >= $minave) {
	    if($minpos < 0) {
		$minpos = $i;
	    }
	    $maxpos = $i;
	}
	# if single position quality is below minq then mark as 'N'
	if($v < $minq) {
	    $slist[$i] = 'n';
	}
    }

    $count_bases_q{$whichread} += $maxpos-$minpos+1;

    if($maxpos >= $minpos && $minpos >= 0) {
	$trimseq = substr($seq, $minpos, ($maxpos-$minpos+1));
    }
    my $retseq = "";
    if(length($trimseq) > $minlen) {
	$retseq = ">".$head."\n".$trimseq."\n";
    }
    return $retseq;
}
