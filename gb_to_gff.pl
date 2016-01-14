#!/usr/bin/env perl
use strict;
use Bio::SeqIO;

# requires BioPerl: http://search.cpan.org/~cjfields/BioPerl/

my $infile = shift;

unless($infile) {
    die "Usage: $0 [Genbank file]\n";
}

my $objseqio = Bio::SeqIO->new(-file => $infile);
$objseqio->verbose(-1);   # repress warnings

while(my $objseq = $objseqio->next_seq) {

    my $acc = $objseq->accession_number;
    
    foreach my $objfeat ($objseq->get_SeqFeatures) {
	my $feature = $objfeat->primary_tag;

	if($feature eq 'source' || $feature eq 'gene' || $feature eq 'CDS') {
	    my $protid = "";
	    my $prod_ann = "";
	    my $dbxref = "";
	    my $locus = "";
	    my @others = ();
	    my $strand = ($objfeat->strand == 1) ? "+" : "-";

	    if($objfeat->has_tag('protein_id')) {
		($protid) = $objfeat->get_tag_values('protein_id');
	    }
	    if($objfeat->has_tag('product')) {
		($prod_ann) = $objfeat->get_tag_values('product');
	    }
	    if($objfeat->has_tag('db_xref')) {
		($dbxref) = $objfeat->get_tag_values('db_xref');
	    }
	    if($objfeat->has_tag('gene')) {
		($locus, @others) = $objfeat->get_tag_values('gene');
		if(scalar(@others) > 0) {
		    print STDERR "Multiple gene values for CDS on $acc\n";
		}
	    } elsif($objfeat->has_tag('locus_tag')) {
		($locus, @others) = $objfeat->get_tag_values('locus_tag');
		if(scalar(@others) > 0) {
		    print STDERR "Multiple locus_tag values for CDS on $acc\n";
		}
	    }
	
	    if(length($locus) > 0) {
		my @att_list = ();
		push(@att_list, "gene_id \"".$locus."\"");
		if(length($protid) > 0) {
		    push(@att_list, "protein_id \"".$protid."\"");
		}
		if(length($dbxref) > 0) {
		    push(@att_list, "db_xref \"".$dbxref."\"");
		}
		if(length($prod_ann) > 0) {
		    push(@att_list, "product \"".$prod_ann."\"");
		}
		
		my $attstr = join("; ", @att_list);
		
		if ($objfeat->location->isa('Bio::Location::SplitLocationI')) {
		    for my $location ( $objfeat->location->sub_Location) {
			my $frame = ($location->end - $location->start + 1) % 3;
			print join("\t", ($acc, "genbank", $feature, $location->start, $location->end, 0, $strand, $frame, $attstr))."\n";
		    }
		} else {
		    my $frame = ($objfeat->location->end - $objfeat->location->start + 1) % 3;
		    print join("\t", ($acc, "genbank", $feature, $objfeat->location->start, $objfeat->location->end, 0, $strand, $frame, $attstr))."\n";
		}
	    } else {
		print join("\t", ($acc, "genbank", $feature, $objfeat->location->start, $objfeat->location->end, 0, ".", "."))."\n";
	    }
	}
    }
}
