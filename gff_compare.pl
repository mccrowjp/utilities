#!/usr/bin/env perl
use strict;

# list of all gene identifiers
my @keys = ('ID', 'transcriptId' ,'proteinId');

my %idctg;
my %idstrand;
my %idstart;
my %idend;
my %index_ctg;
my %index_strand;
my %index_id1;
my %index_id2;
my %index_pos1;
my %index_pos2;
my %index_minpos;
my %index_status;
my $index = 0;

###

sub minpos {
    my ($p1, $p2) = @_;
    my $r = $p1;
    if((length($p1) > 0 && length($p2) > 0 && $p2 < $p1) || (length($p1) == 0 && length($p2) > 0)) {
        $r = $p2;
    }
    return $r;
}

sub addindex {
    my ($ctg, $strand, $id1, $s1, $e1, $id2, $s2, $e2) = @_;

    $index++;
    $index_id1{$index} = $id1;
    $index_id2{$index} = $id2;
    $index_ctg{$index} = $ctg;
    $index_strand{$index} = $strand;
    $index_pos1{$index} = $s1."\t".$e1;
    $index_pos2{$index} = $s2."\t".$e2;
    $index_minpos{$index} = minpos($s1, $s2);
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

sub addindex_merge {
    my ($ctg, $strand, $id1, $s1, $e1, $id2, $s2, $e2, $status) = @_;
    
    $index++;
    $index_id1{$index} = $id1;
    $index_id2{$index} = $id2;
    $index_ctg{$index} = $ctg;
    $index_strand{$index} = $strand;
    $index_pos1{$index} = $s1."\t".$e1;
    $index_pos2{$index} = $s2."\t".$e2;
    $index_minpos{$index} = minpos($s1, $s2);
    $index_status{$index} = $status;
}

###

my ($infile1, $infile2, @rest) = @ARGV;

unless($infile1 && $infile2) {
    die "Usage: $0 [GFF file 1] [GFF file 2] ([optional gene identifiers]... (default: ID transcriptId proteinId))\n";
}

if(scalar(@rest) > 0) {
    @keys = @rest;
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
        
            $strand = substr($strand, 0, 1);
            unless($strand eq '-') {   # unidentified strand assumed to be +
                $strand = '+';
            }
        
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
                    $idstrand{$file}{$id} = $strand;
                    
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

print STDERR "comparing genes: ".scalar(keys %{$idctg{$infile1}}).", ".scalar(keys %{$idctg{$infile2}})."\n";

foreach my $strand ('+', '-') {
    my @ordered_ids1 = ();
    my @ordered_ids2 = ();
    
    foreach my $id (sort {$idctg{$infile1}{$a} cmp $idctg{$infile1}{$b} || $idstart{$infile1}{$a}<=>$idstart{$infile1}{$b} || $idend{$infile1}{$a}<=>$idend{$infile1}{$b}} keys %{$idctg{$infile1}}) {
        if($idstrand{$infile1}{$id} eq $strand) {
            push(@ordered_ids1, $id);
        }
    }
    foreach my $id (sort {$idctg{$infile2}{$a} cmp $idctg{$infile2}{$b} || $idstart{$infile2}{$a}<=>$idstart{$infile2}{$b} || $idend{$infile2}{$a}<=>$idend{$infile2}{$b}} keys %{$idctg{$infile2}}) {
        if($idstrand{$infile2}{$id} eq $strand) {
            push(@ordered_ids2, $id);
        }
    }

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
            addindex($ctg2, $strand, "", "", "", $ordered_ids2[$i2], $s2, $e2);
            $i2++;
        } elsif($i2 >= scalar(@ordered_ids2)) {
            addindex($ctg1, $strand, $ordered_ids1[$i1], $s1, $e1, "", "", "");
            $i1++;
            
        } else {
            if($ctg1 eq $ctg2) {
                # overlap
                if(($s1 <= $s2 && $e1 > $s2) ||
                ($s1 >= $s2 && $e2 > $s1)) {
                    # exact match, status kept
                    if($s1 == $s2 && $e1 == $e2) {
                        addindex($ctg1, $strand, $ordered_ids1[$i1], $s1, $e1, $ordered_ids2[$i2], $s2, $e2);
                        $i1++;
                        $i2++;
                    } else {
                        my $lh_overlap1 = 0;
                        my $lh_overlap2 = 0;
                        my $lh1 = 0;
                        my $lh2 = 0;
                        my $r = 0;
                        
                        # find look-ahead overlaps, for join/split status
                        do {
                            $r++;
                            $lh1 = 0;
                            $lh2 = 0;
                            my $lh_ctg1 = $idctg{$infile1}{$ordered_ids1[$i1+$r]};
                            my $lh_s1 = $idstart{$infile1}{$ordered_ids1[$i1+$r]};
                            my $lh_e1 = $idend{$infile1}{$ordered_ids1[$i1+$r]};
                            my $lh_ctg2 = $idctg{$infile2}{$ordered_ids2[$i2+$r]};
                            my $lh_s2 = $idstart{$infile2}{$ordered_ids2[$i2+$r]};
                            my $lh_e2 = $idend{$infile2}{$ordered_ids2[$i2+$r]};
                            
                            if($ctg1 eq $lh_ctg2 && $e1 > $lh_s2) {
                                $lh_overlap1 = $r;
                                $lh1 = 1;
                            }
                            if($ctg2 eq $lh_ctg1 && $e2 > $lh_s1) {
                                $lh_overlap2 = $r;
                                $lh2 = 1;
                            }
                        } while($lh1 || $lh2);
                        
                        if($lh_overlap1 > 0 && $lh_overlap2 == 0) {
                            my $contains_exact_match = 0;
                            for(my $r=0; $r<=$lh_overlap1; $r++) {
                                if($s1 == $idstart{$infile2}{$ordered_ids2[$i2+$r]} && $e1 == $idend{$infile2}{$ordered_ids2[$i2+$r]}) {
                                    $contains_exact_match = 1;
                                }
                            }
                            for(my $r=0; $r<=$lh_overlap1; $r++) {
                                if($contains_exact_match) {
                                    if($s1 == $idstart{$infile2}{$ordered_ids2[$i2+$r]} && $e1 == $idend{$infile2}{$ordered_ids2[$i2+$r]}) {
                                        addindex_merge($ctg1, $strand, $ordered_ids1[$i1], $s1, $e1, $ordered_ids2[$i2+$r], $idstart{$infile2}{$ordered_ids2[$i2+$r]}, $idend{$infile2}{$ordered_ids2[$i2+$r]}, 'kept');
                                    } else {
                                        addindex_merge($ctg1, $strand, "", "", "", $ordered_ids2[$i2+$r], $idstart{$infile2}{$ordered_ids2[$i2+$r]}, $idend{$infile2}{$ordered_ids2[$i2+$r]}, 'new');
                                    }
                                } else {
                                    addindex_merge($ctg1, $strand, $ordered_ids1[$i1], $s1, $e1, $ordered_ids2[$i2+$r], $idstart{$infile2}{$ordered_ids2[$i2+$r]}, $idend{$infile2}{$ordered_ids2[$i2+$r]}, 'split');
                                }
                            }
                            $i1++;
                            $i2 += 1 + $lh_overlap1;
                            
                        } elsif($lh_overlap2 > 0 && $lh_overlap1 == 0) {
                            my $contains_exact_match = 0;
                            for(my $r=0; $r<=$lh_overlap2; $r++) {
                                if($s2 == $idstart{$infile1}{$ordered_ids1[$i1+$r]} && $e2 == $idend{$infile1}{$ordered_ids1[$i1+$r]}) {
                                    $contains_exact_match = 1;
                                }
                            }
                            for(my $r=0; $r<=$lh_overlap2; $r++) {
                                if($contains_exact_match) {
                                    if($s2 == $idstart{$infile1}{$ordered_ids1[$i1+$r]} && $e2 == $idend{$infile1}{$ordered_ids1[$i1+$r]}) {
                                        addindex_merge($ctg2, $strand, $ordered_ids1[$i1+$r], $idstart{$infile1}{$ordered_ids1[$i1+$r]}, $idend{$infile1}{$ordered_ids1[$i1+$r]}, $ordered_ids2[$i2], $s2, $e2, 'kept');
                                    } else {
                                        addindex_merge($ctg2, $strand, $ordered_ids1[$i1+$r], $idstart{$infile1}{$ordered_ids1[$i1+$r]}, $idend{$infile1}{$ordered_ids1[$i1+$r]}, "", "", "", 'deleted');
                                    }
                                } else {
                                    addindex_merge($ctg2, $strand, $ordered_ids1[$i1+$r], $idstart{$infile1}{$ordered_ids1[$i1+$r]}, $idend{$infile1}{$ordered_ids1[$i1+$r]}, $ordered_ids2[$i2], $s2, $e2, 'join');
                                }
                            }
                            $i1 += 1 + $lh_overlap2;
                            $i2++;
                            
                        } else {
                            addindex($ctg1, $strand, $ordered_ids1[$i1], $s1, $e1, $ordered_ids2[$i2], $s2, $e2);
                            $i1++;
                            $i2++;
                        }
                    }
                    
                } else {
                    if($s1 < $s2) {
                        addindex($ctg1, $strand, $ordered_ids1[$i1], $s1, $e1, "", "", "");
                        $i1++;
                    } else {
                        addindex($ctg2, $strand, "", "", "", $ordered_ids2[$i2], $s2, $e2);
                        $i2++;
                    }
                }
                $lastctg = $ctg1;
                
            } else {
                if($ctg1 eq $lastctg) {
                    addindex($ctg1, $strand, $ordered_ids1[$i1], $s1, $e1, "", "", "");
                    $i1++;
                    $lastctg = $ctg1;

                } elsif($ctg2 eq $lastctg) {
                    addindex($ctg2, $strand, "", "", "", $ordered_ids2[$i2], $s2, $e2);
                    $i2++;
                    $lastctg = $ctg2;
                    
                } else {
                    $lastctg = ($ctg1 cmp $ctg2) < 0 ? $ctg1 : $ctg2;
                }
            }
        }
    }
}

my %statuscount;

print join("\t", ('ctg', 'strand', 'id_1', 'start_1', 'end_1', 'id_2', 'start_2', 'end_2', 'status'))."\n";
foreach my $i (sort {$index_ctg{$a} cmp $index_ctg{$b} || $index_minpos{$a}<=>$index_minpos{$b}} keys %index_ctg) {
    print join("\t", ($index_ctg{$i}, $index_strand{$i}, $index_id1{$i}, $index_pos1{$i}, $index_id2{$i}, $index_pos2{$i}, $index_status{$i}))."\n";
    $statuscount{$index_status{$i}}++;
}

foreach my $status (sort {$statuscount{$b}<=>$statuscount{$a}} keys %statuscount) {
    print STDERR $statuscount{$status}."\t".$status."\n";
}
