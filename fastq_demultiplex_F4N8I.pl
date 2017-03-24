#!/usr/bin/env perl
#
# Demultiplex paired FASTQ files, by forward read 4N + 8 index bases
#

use strict;

my ($fqR1file, $fqR2file, $adaptseq, $outbase) = @ARGV;

$adaptseq =~ tr/a-z/A-Z/;
my $indexlen = length($adaptseq);

unless(length($fqR1file) > 0 && length($fqR2file) > 0 && $indexlen > 0) {
    die "Usage: $0 [FASTQ R1 file] [FASTQ R2 file] [Adapter index sequence] ([Output base name])\n";
}

unless(length($outbase) > 0) {
    $outbase = $fqR1file;
    $outbase =~ s/\.(fastq|fq)$//i;
    $outbase =~ s/_R1.*$//;
    $outbase .= "_".$adaptseq;
}

my $outfile1 = $outbase."_R1.fastq";
my $outfile2 = $outbase."_R2.fastq";

if($fqR1file =~ /\.gz$/) {
    open(IN1, "gunzip -c $fqR1file 2>/dev/null |");
} else {
    open(IN1, $fqR1file) or die "Unable to open file $fqR1file\n";
}

if($fqR2file =~ /\.gz$/) {
    open(IN2, "gunzip -c $fqR2file 2>/dev/null |");
} else {
    open(IN2, $fqR2file) or die "Unable to open file $fqR2file\n";
}

open(OUT1, ">".$outfile1) or die "Unable to write to file $outfile1\n";
open(OUT2, ">".$outfile2) or die "Unable to write to file $outfile2\n";

print STDERR "forward read 4N + $adaptseq:\n";
print STDERR "$fqR1file -> $outfile1\n";
print STDERR "$fqR2file -> $outfile2\n";

my $sn = 0;
my $isgood = 0;
my $count_good = 0;
my $count_total = 0;
my $line1;
my $line2;
my $rec1;
my $rec2;

###

sub write_records {
    if($isgood) {
        print OUT1 $rec1;
        print OUT2 $rec2;
    }
}

###

do {
    $sn++;
    if($sn > 4) {
        write_records();
        $sn = 1;
        $isgood = 0;
        $rec1 = "";
        $rec2 = "";
    }
    if(defined($line1 = <IN1>) && defined($line2 = <IN2>)) {
        if($sn == 2) {
            $count_total++;
            if(substr($line1, 4, $indexlen) eq $adaptseq) {
                $isgood = 1;
                $count_good++;
            }
        }
        if($sn == 2 || $sn == 4) {
            $rec1 .= substr($line1, $indexlen+4);
            $rec2 .= substr($line2, $indexlen+4);
        } else {
            $rec1 .= $line1;
            $rec2 .= $line2;
        }
    }
    
} until(eof IN1 || eof IN2);
write_records();

close(IN1);
close(IN2);

close(OUT1);
close(OUT2);

print STDERR "Extracted: $count_good of $count_total\n";
