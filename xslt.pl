#!/usr/bin/env perl
use strict;
use XML::LibXSLT;

my $inxml = shift;
my $inxsl = shift;

if($inxml && $inxsl) {
} else {
    die "Usage: $0 [XML Document] [XSL Stylesheet]\n";
}

my $xslt = XML::LibXSLT->new;
my $ss = $xslt->parse_stylesheet_file($inxsl);
my $t = $ss->transform_file($inxml);

print $ss->output_string($t);
