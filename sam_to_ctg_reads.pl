#!/usr/bin/env perl
use strict;

my $samfile = shift;
my $ctgfile = shift;

my %ctgs;
my %readctg;

unless($samfile && $ctgfile) {
    die "Usage: $0 [SAM file (- for STDIN)] [List of contig names file]\n";
}

open(IN, $ctgfile) or die "Unable to open file $ctgfile\n";
while(<IN>) {
    chomp;
    my ($id) = split(/[\s\t]/);
    $ctgs{$id} = 1;
}
close(IN);

if($samfile eq '-') {
    open(IN, "<&=STDIN") or die "Unable to read from STDIN\n";
} else {
    open(IN, $samfile) or die "Unable to open file $samfile\n";
}
while(<IN>) {
    my ($readid, $flag, $ctgid) = split(/\t/);
    if($ctgs{$ctgid}) {
# if a read is mapped to more than one ctg, use primary line (flag == 0)
        if($flag & 0x900 == 0 || !exists($readctg{$readid})) {
            $readctg{$readid} = $ctgid;
        }
    }
}
close(IN);

foreach my $readid (sort {$readctg{$a} cmp $readctg{$b} || $a cmp $b} keys %readctg) {
    print $readctg{$readid}."\t".$readid."\n";
}
