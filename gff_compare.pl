#!/usr/bin/env perl
use strict;

# list of all keys that identify the gene identifier
my @keys = ('ID', 'transcriptId' ,'proteinId');

my %idctg;
my %idstart;
my %idend;
my %found1;
my %found2;
my %index_ctg;
my %index_id1;
my %index_id2;
my %index_pos1;
my %index_pos2;
my %index_status;
my $index = 0;

###

sub addindex {
    my ($ctg, $id1, $s1, $e1, $id2, $s2, $e2) = @_;
    $found1{$id1}++ if length($id1) > 0;
    $found2{$id2}++ if length($id2) > 0;

    $index++;
    $index_id1{$index} = $id1;
    $index_id2{$index} = $id2;
    $index_ctg{$index} = $ctg;
    $index_pos1{$index} = $s1."\t".$e1;
    $index_pos2{$index} = $s2."\t".$e2;
    if($s1 == $s2 && $e1 == $e2) {
        $index_status{$index} = 'kept';
    } elsif(length($id1) > 0 && length($id2) > 0) {
        $index_status{$index} = 'modified';
    } elsif(length($id1) > 0) {
        $index_status{$index} = 'deleted';
    } else {
        $index_status{$index} = 'new';
    }
}

###

my $infile1 = shift;
my $infile2 = shift;

unless($infile1 && $infile2) {
    die "Usage: $0 [GFF file 1] [GFF file 2]\n";
}

foreach my $file ($infile1, $infile2) {
    if($file =~ /\.gz$/) {
        open(IN, "gunzip -c $file 2>/dev/null |");
    } else {
        open(IN, $file) or die "Unable to open file $file\n";
    }
    print STDERR "reading $file\n";

    while(<IN>) {
        chomp;
        unless(/^\#/) {
            my ($ctg, $source, $feat, $s, $e, $score, $strand, $frame, $attrstr) = split(/\t/);
            foreach my $att (split(/\s*;\s*/, $attrstr)) {
                my $id = "";
                foreach my $key (@keys) {
                    if($att =~ /^\s*($key)[\=\s]+(.+)$/) {
                        $id = $2;
                        last;
                    }
                }
                if(length($id) > 0) {
                    $id =~ s/[\"\']//g;
                    
                    $idctg{$file}{$id} = $ctg;
                    
                    if(!defined($idstart{$file}{$id}) || $s < $idstart{$file}{$id}) {
                        $idstart{$file}{$id} = $s;
                    }
                    
                    if(!defined($idend{$file}{$id}) || $e > $idend{$file}{$id}) {
                        $idend{$file}{$id} = $e;
                    }
                }
            }
        }
    }
}

my @ordered_ids1 = (sort {$idctg{$infile1}{$a} cmp $idctg{$infile1}{$b} || $idstart{$infile1}{$a}<=>$idstart{$infile1}{$b}} keys %{$idctg{$infile1}});
my @ordered_ids2 = (sort {$idctg{$infile2}{$a} cmp $idctg{$infile2}{$b} || $idstart{$infile2}{$a}<=>$idstart{$infile2}{$b}} keys %{$idctg{$infile2}});

print STDERR "comparing genes: ".scalar(@ordered_ids1).", ".scalar(@ordered_ids2)."\n";

my $i1 = 0;
my $i2 = 0;
my $lastctg;

while($i1 < scalar(@ordered_ids1) || $i2 < scalar(@ordered_ids2)) {
    my $ctg1 = $idctg{$infile1}{$ordered_ids1[$i1]};
    my $s1 = $idstart{$infile1}{$ordered_ids1[$i1]};
    my $e1 = $idend{$infile1}{$ordered_ids1[$i1]};
    my $ctg2 = $idctg{$infile2}{$ordered_ids2[$i2]};
    my $s2 = $idstart{$infile2}{$ordered_ids2[$i2]};
    my $e2 = $idend{$infile2}{$ordered_ids2[$i2]};
    
    if($i1 >= scalar(@ordered_ids1)) {
        addindex($ctg2, "", "", "", $ordered_ids2[$i2], $s2, $e2);
        $i2++;
    } elsif($i2 >= scalar(@ordered_ids2)) {
        addindex($ctg1, $ordered_ids1[$i1], $s1, $e1, "", "", "");
        $i2++;
        
    } else {
        if($ctg1 eq $ctg2) {
            # overlap
            if(($s1 <= $s2 && $e1 > $s2) ||
            ($s1 >= $s2 && $e2 > $s1)) {
                addindex($ctg1, $ordered_ids1[$i1], $s1, $e1, $ordered_ids2[$i2], $s2, $e2);
                $i1++;
                $i2++;
                
            } else {
                if($s1 < $s2) {
                    addindex($ctg1, $ordered_ids1[$i1], $s1, $e1, "", "", "");
                    $i1++;
                } else {
                    addindex($ctg2, "", "", "", $ordered_ids2[$i2], $s2, $e2);
                    $i2++;
                }
            }
            $lastctg = $ctg1;
            
        } else {
            if($ctg1 eq $lastctg) {
                addindex($ctg1, $ordered_ids1[$i1], $s1, $e1, "", "", "");
                $i1++;
                $lastctg = $ctg1;

            } elsif($ctg2 eq $lastctg) {
                addindex($ctg2, "", "", "", $ordered_ids2[$i2], $s2, $e2);
                $i2++;
                $lastctg = $ctg2;
                
            } else {
                $lastctg = ($ctg1 cmp $ctg2) < 0 ? $ctg1 : $ctg2;
            }
        }
    }
}

my %statuscount;

print join("\t", ('ctg','id_1', 'start_1', 'end_1', 'id_2', 'start_2', 'end_2', 'status'))."\n";
for(my $i=1; $i<=$index; $i++) {
    print join("\t", ($index_ctg{$i}, $index_id1{$i}, $index_pos1{$i}, $index_id2{$i}, $index_pos2{$i}, $index_status{$i}))."\n";
    $statuscount{$index_status{$i}}++;
}

foreach my $status (sort {$statuscount{$b}<=>$statuscount{$a}} keys %statuscount) {
    print STDERR $statuscount{$status}."\t".$status."\n";
}

foreach my $id (sort {$found1{$b}<=>$found1{$a}} keys %found1) {
    if($found1{$id} > 1) {
        print STDERR "split\t".$found1{$id}."\n";
    }
}
foreach my $id (sort {$found2{$b}<=>$found2{$a}} keys %found2) {
    if($found2{$id} > 1) {
        print STDERR "joined\t".$found2{$id}."\n";
    }
}
