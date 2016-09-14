#!/usr/bin/env perl
use strict;

my @filelist = @ARGV;

unless(scalar(@filelist) > 1) {
    die "Usage: $0 [GFF files...]\n";
}

my %featdat;
my $count_in = 0;
my $count_out = 0;
my $count_covered = 0;

foreach my $file (@filelist) {
    if($file =~ /\.gz$/) {
        open(IN, "gunzip -c $file 2>/dev/null |");
    } else {
        open(IN, $file) or die "Unable to open file $file\n";
    }

    my $count_file = 0;
    while(<IN>) {
        chomp;
        unless(/^\#/) {
            $count_in++;
            $count_file++;
            my ($ctg, $source, $feat, $s, $e, $score, $strand, $frame, $attrstr) = split(/\t/);
            my $key = join("\t", ($ctg, $s, $e));
        
            if(!exists($featdat{$key}) || $score > $featdat{$key}{'score'}) {
                $featdat{$key}{'ctg'} = $ctg;
                $featdat{$key}{'s'} = $s;
                $featdat{$key}{'e'} = $e;
                $featdat{$key}{'source'} = $source;
                $featdat{$key}{'feat'} = $feat;
                $featdat{$key}{'score'} = $score;
                $featdat{$key}{'strand'} = $strand;
                $featdat{$key}{'frame'} = $frame;
                $featdat{$key}{'attrstr'} = $attrstr;
            }
        }
    }
    close(IN);

    print STDERR $count_file."\t".$file."\n";
}

print "# [".localtime()."] gff_merge.pl ".join(" ", @filelist)."\n";

my %maxctgend;

foreach my $key (sort {$featdat{$a}{'ctg'} cmp $featdat{$b}{'ctg'} ||
                        $featdat{$a}{'s'}<=>$featdat{$b}{'s'} ||
                        $featdat{$b}{'e'}<=>$featdat{$a}{'e'} ||
                        $featdat{$b}{'score'}<=>$featdat{$a}{'score'}} keys %featdat) {
                        
    my $ctg = $featdat{$key}{'ctg'};
    my $s = $featdat{$key}{'s'};
    my $e = $featdat{$key}{'e'};
    my $source = $featdat{$key}{'source'};
    my $feat = $featdat{$key}{'feat'};
    my $score = $featdat{$key}{'score'};
    my $strand = $featdat{$key}{'strand'};
    my $frame = $featdat{$key}{'frame'};
    my $attrstr = $featdat{$key}{'attrstr'};
                            
    if($e > $maxctgend{$ctg}) {
        $maxctgend{$ctg} = $e;
        print join("\t", ($ctg, $source, $feat, $s, $e, $score, $strand, $frame, $attrstr))."\n";
        $count_out++;
        
    } else {
        $count_covered++;
        # skip smaller covered regions
    }
}

print STDERR "Files merged:     ".scalar(@filelist)."\n";
print STDERR "Input features:   $count_in\n";
print STDERR "Skipped features: $count_covered\n";
print STDERR "Merged features:  $count_out\n";
