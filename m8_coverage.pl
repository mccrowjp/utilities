#!/usr/bin/env perl
use strict;
use Getopt::Long;

my $ethresh = 0;
my $binsize = 1;
my $covfile;
my $reffile;
my $outfile;

my %idlen;
my %ctgposmaxpid;

GetOptions ("o=s" => \$outfile,
            "c=s" => \$covfile,
            "r=s" => \$reffile,
            "b=i" => \$binsize,
            "e=f" => \$ethresh);

my $infile = shift;

my $help = <<HELP;
Usage: $0 (options) [Blast m8 file]

  -b int   : Bin size for coverage output (default: 1)
  -c file  : Base coverage output file (default: none)
  -e real  : E-value threshold (default: Infinity)
  -o file  : Output file (default: STDOUT)
  -r file  : Reference FASTA (default: full lengths inferred from Blast output)
  
HELP

unless($infile) {
    die $help;
}

if(length($reffile) > 0) {
    if($reffile =~ /\.gz$/) {
        open(IN, "gunzip -c $reffile 2>/dev/null |");
    } else {
        open(IN, $reffile) or die "Unable to open file $reffile\n";
    }
    print STDERR "reading $reffile\n";

    my $id = "";
    while(<IN>) {
        if(/^>/) {
            ($id) = split(/\s+/, $');
        } else {
            s/[^A-Za-z]//g;
            $idlen{$id} += length($_);
        }
    }
}

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |");
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}
print STDERR "reading $infile\n";

while(<IN>) {
    chomp;
    my ($qid, $sid, $pid, $len, $mm, $go, $qs, $qe, $ss, $se, $e, $bs) = split(/\t/);
    
    # update lengths if not given, or if shorter than possible from blast output
    if($se > $idlen{$sid}) {
        $idlen{$sid} = $se;
    }
    
    if($ethresh == 0 || $e <= $ethresh) {
        if($pid < 0.1) {
            $pid = 0.1;
        }
        for(my $i=$ss; $i<=$se; $i++) {
            if($pid > $ctgposmaxpid{$sid}{$i}) {
                $ctgposmaxpid{$sid}{$i} = $pid;
            }
        }
    }
}
close(IN);

if(length($outfile) > 0) {
    open(OUT, ">".$outfile) or die "Unable to write to file $outfile\n";
    print STDERR "writing $outfile\n";
} else {
    open(OUT, ">&=STDOUT") or die "Unable to write to STDOUT\n";
}

my $len_match = 0;
my $len_total = 0;
my $sum_pid = 0;
foreach my $ctg (keys %idlen) {
    $len_total += $idlen{$ctg};
    foreach my $pos (keys %{$ctgposmaxpid{$ctg}}) {
        $len_match++;
        $sum_pid += $ctgposmaxpid{$ctg}{$pos};        
    }
}

printf OUT "Bases total:         %d\n", $len_total;
printf OUT "Bases aligned (%s):   %d (%.1f)\n", '%', $len_match, 100.0*$len_match/$len_total;
printf OUT "Average %s-identity: %.1f\n", '%', $sum_pid/$len_match; 

close(OUT);

if(length($covfile) > 0) {
    open(OUTCOV, ">".$covfile) or die "Unable to write to file $covfile\n";
    print STDERR "writing $covfile\n";

    my $pos = 0;
    my $binn = 0;
    my $pidsum = 0;
    foreach my $ctg (sort {$idlen{$b}<=>$idlen{a}} keys %idlen) {
        for(my $i=0; $i<$idlen{$ctg}; $i++) {
            $pos++;
            $binn++;
            $pidsum += $ctgposmaxpid{$ctg}{$i};
            if($binn >= $binsize) {
                printf OUTCOV "%d\t%.1f\n", $pos, $pidsum/$binn;
                $binn = 0;
                $pidsum = 0;
            }
        }
    }
    if($binn > 0) {
        printf OUTCOV "%d\t%.1f\n", $pos, $pidsum/$binn;
    }
    
    close(OUTCOV);
}
