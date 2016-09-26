#!/usr/bin/env perl
use strict;
use Getopt::Long;

#
# Input: Nucleotide fasta 
# Counts various GC related metrics, and kmers (reverse complement pairs, to avoid strand bias)
#

my $listsep1 = ",";
my $listsep2 = ":";
my $tabsep = "\t";
my @kmerorder;

my $seq;
my $id;
my %kmercount;
my $ntcount;
my $gccount;
my $npntcount;
my $npgccount;
my $cpgcount;
my %codonposcount;
my %codonposgccount;
my $totkmers;

my $infile;
my $k = 4;
my $asTable = 0;
my $allSeqs = 0;

###

sub revcomp($) {
    my $str = shift;
    $str =~ tr/ACGTacgt/TGCAtgca/;
    return reverse($str);
}

sub resetCounts() {
    %kmercount = ();
    $ntcount = 0;
    $gccount = 0;
    $npntcount = 0;
    $npgccount = 0;
    $cpgcount = 0;
    %codonposcount = ();
    %codonposgccount = ();
    $totkmers = 0;
}

sub printRecord() {
    if(scalar(keys %kmercount) > 0) {
        if($asTable) {
            printTableLine();
        } else {
            printListLine();
        }
    }
}

sub nucComp() {
    
    $seq =~ s/\s//g;
    $seq =~ tr/A-Z/a-z/;
    $seq =~ tr/u/t/;   # for RNA
    
    my $n = length($seq);
    
    if($n > $k) {
        $ntcount += $n;
        
        # GC content
        my $gcstr = $seq;
        $gcstr =~ s/[^gc]//g;
        $gccount += length($gcstr);
        
        # GC content codon position
        my @seqchrs = split(//, $seq);
        my $cp = 1;
        for(my $i=0; $i<scalar(@seqchrs); $i++) {
            if($seqchrs[$i] =~ /[atcg]/) {
                $codonposcount{$cp}++;
            }
            if($seqchrs[$i] =~ /[cg]/) {
                $codonposgccount{$cp}++;
            }
            $cp++;
            if($cp>3) { $cp=1; }
        }
        
        # GC non-poly content (ignore runs of 2 or more of the same base)
        my $ntstr = $seq;
        $ntstr =~ s/aa+/a/g;
        $ntstr =~ s/cc+/c/g;
        $ntstr =~ s/gg+/g/g;
        $ntstr =~ s/tt+/t/g;
        $npntcount += length($ntstr);
        my $gcstr = $ntstr;
        $gcstr =~ s/[^gc]//g;
        $npgccount += length($gcstr);
        
        # CpG content
        my $cpgstr = $seq;
        $cpgstr =~ s/cg//g;
        $cpgcount += $n - length($cpgstr);
        
        # K-mers
        for(my $i=0; $i<$n-$k; $i++) {
            my $kmer = substr($seq, $i, $k);
            my $unknwns = join("", split(/[acgt]+/,$kmer));
            if(length($unknwns) > 0) {
                # skip
            } else {
                # increment kmer and revcomp(kmer) but will only use one
                $kmercount{$kmer}++;
                $kmercount{revcomp($kmer)}++;
                $totkmers++;
            }
        }
    }
}

sub printTableHead() {
    if($allSeqs) {
        print "file";
    } else {
        print "seqID";
    }
    
    print $tabsep."nt";
    print $tabsep."GC";
    print $tabsep."CpG";
    for(my $i=1; $i<=3; $i++) {
        print $tabsep."nt".$i;
        print $tabsep."GC".$i;
    }
    print $tabsep."nonpoly_nt";
    print $tabsep."nonpoly_GC";
    print $tabsep."Kmers";
    foreach my $kmer (@kmerorder) {
        print $tabsep.$kmer;
    }
    print "\n";
}

sub printTableLine() {
    if($allSeqs) {
        print $infile;
    } else {
        my ($name) = split(/\s/, $id);
        print $name;
    }
    
    print $tabsep.$ntcount;
    print $tabsep.$gccount;
    print $tabsep.$cpgcount;
    for(my $i=1; $i<=3; $i++) {
        print $tabsep.$codonposcount{$i};
        print $tabsep.$codonposgccount{$i};
    }
    print $tabsep.$npntcount;
    print $tabsep.$npgccount;
    print $tabsep.$totkmers;
    foreach my $kmer (@kmerorder) {
        printf "%s%d", $tabsep, $kmercount{$kmer};
    }
    print "\n";
}

sub printListLine() {
    print ">";
    if($allSeqs) {
        print $infile;
    } else {
        print $id;
    }
    print "\n";
    
    print "nt:\t$ntcount\n";
    print "GC:\t$gccount\t".sprintf("%.6f", ($gccount/$ntcount))."\n";
    print "CpG:\t$cpgcount\t".sprintf("%.6f", ($cpgcount/$ntcount))."\n";
    for(my $i=1; $i<=3; $i++) {
        print "nt".$i.":\t".$codonposcount{$i}."\n";
        print "GC".$i.":\t".$codonposgccount{$i}."\t".sprintf(".6f", ($codonposgccount{$i}/$codonposcount{$i}))."\n";
    }
    print "nonpoly nt:\t$npntcount\n";
    print "nonpoly GC:\t$npgccount\t".sprintf("%.6f", ($npgccount/$npntcount))."\n";
    print "Kmers:\t$totkmers\n";
    
    my $isfirst = 1;
    foreach my $kmer (sort {$kmercount{$b}<=>$kmercount{$a}} keys %kmercount) {
        if($isfirst) {
        } else {
            print $listsep1;
        }
        print $kmer.$listsep2.$kmercount{$kmer};
        $isfirst = 0;
    }
    print "\n";
}

sub buildKmerOrder() {
    my @nucs = ('a','c','g','t');
    my @kmerchr;
    my %kmerdone;
    
    for(my $i=0; $i<$k; $i++) {
        $kmerchr[$i]=0;
    }
    my $incr=1;
    while($incr) {
        my $str;
        for(my $i=0; $i<$k; $i++) {
            $str .= $nucs[$kmerchr[$i]];
        }
        my $rcstr = revcomp($str);
        if($kmerdone{$rcstr}) {
            # skip reverse complements
        } else {
            push(@kmerorder, $str);
            $kmerdone{$str} = 1;
        }
        
        #increment kmerchr
        $incr=0;
        for(my $j=$k-1; $j>=0; $j--) {
            if(!$incr) {
                if($kmerchr[$j] < 3) {
                    $kmerchr[$j]++;
                    $incr=1;
                } else {
                    $kmerchr[$j]=0;
                }
            }
        }
    }
}

###

GetOptions ("i=s" => \$infile,
	    "k=i" => \$k,
	    "t"   => \$asTable,
	    "c"   => \$allSeqs);

my $options = <<OPTIONS;
  -i file : fasta file input
  -k #    : k-mer size 
            (default: 4)

  -t      : print as table 
            (default: print separate kmer counts)
            only allowed for k <= 5. k>5 would result in a
            very large sparsely populated table

  -c      : combine all sequences into one 
            (default: each sequence separately)

OPTIONS

unless(length($infile) > 0) {
    die "Usage: $0 -i [FASTA file] (options)\n$options";
}
if($asTable && $k>5) {
    die "Must make k<=5 to output as table\n";
}

if($asTable) {
    buildKmerOrder();
}

if($infile =~ /\.gz$/) {
    open(IN, "gunzip -c $infile 2>/dev/null |")
} else {
    open(IN, $infile) or die "Unable to open file $infile\n";
}

print "# ".localtime()." : $0 $infile k=$k\n";
if($asTable) {
    printTableHead();
}

while(<IN>) {
    chomp;
    unless(/^\#/) {
        if(/^\>/) {
            nucComp();
            if($allSeqs) {
            } else {
                printRecord();
                resetCounts();
            }
            $id = $';
            $seq = "";
        } else {
            $seq .= $_;
        }
    }
}
nucComp();
printRecord();

close(IN);
