#!/usr/bin/env perl
use strict;

sub convert_qual {
    my $instr = shift;
    my $outstr = "";

    foreach my $dec (split(/[\s\t\r\n]+/, $instr)) {
	if($dec > 99) {
	    $dec = 99;
	}
	my $v = chr(int($dec) + 33);
	$outstr .= $v;
    }
    return $outstr;
}

sub read_fasta_record {
    my $fhandle = shift;
    my $lasthead = shift;
    
    my $line = "";
    my $head = "";
    my $nexthead = "";
    my $seq = "";
    
    if($lasthead) {
        $head = $lasthead;
    
    } else {
        my $noteof = ($line = <$fhandle>);
        while($noteof && $line =~ /^[\s\t\r\n]+$/) {
            $noteof = ($line = <$fhandle>);
        }
        chomp($line);
        
        if($line =~ /^>(.+)$/) {
            $head = $1;
        } else {
            die "Unexpected header: $line\n";
        }
    }
    
    my $noteof = ($line = <$fhandle>);
    while($noteof && !($line =~ /^>/)) {
        $seq .= $line;
        $noteof = ($line = <$fhandle>);
    }

    chomp($line);
    if($line =~ /^>(.+)$/) {
        $nexthead = $1;
    }
    
    return ($head, $seq, $nexthead);
}

###

my $infa = shift;
my $inqual = shift;
my $option = shift;
my $matchheads = 1;

if($option eq "-i") {
    $matchheads = 0;
}

unless($infa && $inqual) {
    die "Usage: $0 [FASTA file] [QUAL file] ([-i] Ignore header matching)\n";
}

my $fh1;
my $fh2;

if($infa =~ /\.gz$/) {
    open(IN, "gunzip -c $infa 2>/dev/null |");
} else {
    open($fh1, $infa) or die "Unable to open file $infa\n";
}
if($inqual =~ /\.gz$/) {
    open(IN, "gunzip -c $inqual 2>/dev/null |");
} else {
    open($fh2, $inqual) or die "Unable to open file $inqual\n";
}

my ($head1, $seq, $nexthead1) = read_fasta_record($fh1);
my ($head2, $qual, $nexthead2) = read_fasta_record($fh2);

while($nexthead1 && $nexthead2) {
    if($matchheads && $head1 ne $head2) {
        die "Headers do not match:\n$head1\n$head2\n";
    }
    $seq =~ s/[\s\t\r\n]//g;
    if($qual =~ /^\d\d\s/) {
	$qual = convert_qual($qual);
    }
    print join("\n", ("@".$head1, $seq, "+", $qual))."\n";
    
    ($head1, $seq, $nexthead1) = read_fasta_record($fh1, $nexthead1);
    ($head2, $qual, $nexthead2) = read_fasta_record($fh2, $nexthead2);
}
close($fh1);
close($fh2);
