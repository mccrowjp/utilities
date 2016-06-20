#!/usr/bin/env perl
use strict;
use Getopt::Long;

my %pepstart;
my %pepstrand;
my %pepseq;
my %ctgpeps;

my $gff_source = 'fasta_to_gff_correct_positions';
my $gff_feature = 'gene';
my $gff_frame = '0';
my $gff_score = '.';
my $max_offset = 3;
my $min_match = 0.8;
my $count = 0;

###

sub codontable {
    my $codon = shift;
    $codon =~ tr/a-z/A-Z/;
    my ($c1, $c2, $c3) = split(//, $codon);
    
    my $aa = ($c1 eq 'T'?($c2 eq 'T'?($c3 eq 'T'||$c3 eq 'C'?'F':'L'):($c2 eq 'C'?'S':($c2 eq 'A'?($c3 eq 'T'||$c3 eq 'C'?'Y':'*'):($c2 eq 'G'?($c3 eq 'T'||$c3 eq 'C'?'C':($c3 eq 'A'?'*':'W')):'X')))):
    ($c1 eq 'C'?($c2 eq 'T'?'L':($c2 eq 'C'?'P':($c2 eq 'A'?($c3 eq 'T'||$c3 eq 'C'?'H':'Q'):($c2 eq 'G'?'R':'X')))):
    ($c1 eq 'A'?($c2 eq 'T'?($c3 eq 'G'?'M':'I'):($c2 eq 'C'?'T':($c2 eq 'A'?($c3 eq 'T'||$c3 eq 'C'?'N':'K'):($c2 eq 'G'?($c3 eq 'T'||$c3 eq 'C'?'S':'R'):'X')))):
    ($c1 eq 'G'?($c2 eq 'T'?'V':($c2 eq 'C'?'A':($c2 eq 'A'?($c3 eq 'T'||$c3 eq 'C'?'D':'E'):($c2 eq 'G'?'G':'X')))):'X'))));
    return $aa;
}

sub translate {
    my $seq = shift;
    $seq =~ s/ //g;
    my $retseq = "";
    
    if(length($seq) > 0) {
        my @nts = split(//, $seq);
        my $c = "";
        for(my $i=0; $i<scalar(@nts); $i++) {
            $c .= $nts[$i];
            if(length($c) == 3) {
                my $aa = codontable($c);
                $retseq .= $aa;
                $c = "";
            }
        }
    }
    return $retseq;
}

sub revcomp {
    my $seq = shift;
    $seq =~ tr/ACGTacgt/TGCAtgca/;
    return reverse($seq);
}

sub correct_positions {
    my ($ctg, $ctgseq) = @_;
    if($ctg && $ctgseq) {
        my $n = length($ctgseq);
        foreach my $pep (@{$ctgpeps{$ctg}}) {
            my $strand = $pepstrand{$pep};
            my $s = $pepstart{$pep};
            my $aalen = length($pepseq{$pep});
            my $len = $aalen * 3;
            my @aa_pep = split(//, $pepseq{$pep});
            my $bestmatch = -1;
            my $bestpos;
            
            my @poslist = ($s-1);
            for(my $i=1; $i<=$max_offset; $i++) {
                if($s-1+$i+$len-1 <= $n) {
                    push(@poslist, $s-1+$i);
                }
                if($s-1-$i >= 0) {
                    push(@poslist, $s-1-$i);
                }
            }
            
            foreach my $pos (@poslist) {
                if($bestmatch / $aalen < $min_match) {
                    my $sub = substr($ctgseq, $pos, $len);
                    if($strand eq '-') {
                        $sub = revcomp($sub);
                    }
                    my $trans = translate($sub);
                    my @aa_ref = split(//, $trans);
            
                    my $match = 0;
                    for(my $i=0; $i<$aalen; $i++) {
                        if($aa_pep[$i] eq $aa_ref[$i]) {
                            $match++;
                        }
                    }
                    if($match > $bestmatch) {
                        $bestmatch = $match;
                        $bestpos = $pos;
                    }
                }
            }
            
            my $gff_chr = $ctg;
            my $gff_s = $bestpos + 1;
            my $gff_e = $gff_s + $len - 1;
            my $gff_strand = $strand;
            my $gff_attr = $gff_feature."_id \"$pep\"; translation_match \"".sprintf("%d", 100.0*$bestmatch/$aalen)."\"";

            print join("\t", ($gff_chr, $gff_source, $gff_feature, $gff_s, $gff_e, $gff_score, $gff_strand, $gff_frame, $gff_attr))."\n";
            
            $count++;
            if($count % 10000 == 0) {
                print STDERR $count."\n";
            }
        }
    }
}

###

GetOptions ("s=s" => \$gff_source,
            "f=s" => \$gff_feature);

my $ctgfile = shift;
my $pepfile = shift;

my $help = <<HELP;
Usage: $0 (options) [Contig FASTA file] [ORF peptide FASTA file]

  FASTA IDs have format returned by FragGeneScan or similar 
  (eg. contig_1234_5_200_+  with start, end, and strand separated by '_')
  
  -s text  : Source to list (project, database, or program name)
             [Default: fasta_to_gff_correct_positions]

  -f text  : Feature type (typical values: gene, transcript, CDS, exon)
             [Default: gene]

HELP

unless($ctgfile && $pepfile) {
    die $help;
}

if($pepfile =~ /.gz$/) {
    open(IN, "gunzip -c $pepfile 2>/dev/null |");
} else {
    open(IN, $pepfile) or die "Unable to open file $pepfile\n";
}
print STDERR "reading $pepfile\n";

my $id;
while(<IN>) {
    chomp;
    if(/^>/) {
        if(/^>([^\s]+)_(\d+)_(\d+)_([\+\-])$/) {
            my ($ctg, $start, $end, $strand) = ($1, $2, $3, $4);
            $id = join("_", ($ctg, $start, $end, $strand));
            push(@{$ctgpeps{$ctg}}, $id);
            $pepstart{$id} = $start;
            $pepstrand{$id} = $strand;
            
        } else {
            die "Unexpected peptide ID: $id\n";
        }
    } else {
        s/[^A-Za-z]+//g;
        $pepseq{$id} .= $_;
    }
}
close(IN);

print STDERR "Peptides: ".scalar(keys %pepstart)."\n";

if($ctgfile =~ /.gz$/) {
    open(IN, "gunzip -c $ctgfile 2>/dev/null |");
} else {
    open(IN, $ctgfile) or die "Unable to open file $ctgfile\n";
}
print STDERR "reading $ctgfile\n";

my $id;
my $seq = "";
while(<IN>) {
    chomp;
    if(/^>/) {
        correct_positions($id, $seq);
        ($id) = split(/[\s\t\r\n]+/, $');   #');
        $seq = "";
    } else {
        s/[^A-Za-z]+//g;
        $seq .= $_;
    }
}
correct_positions($id, $seq);
close(IN);
