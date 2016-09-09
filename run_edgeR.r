#!/usr/bin/env Rscript
#
# EdgeR for differential expression from replicate sample ORF counts table
#
args <- commandArgs(TRUE)
infile = paste("", args[1], sep="")
outfile = paste("", args[2], sep="")

if(infile == 'NA' || outfile == 'NA') {
    message("Usage: run_edgeR.r [input file] [output file]")
    message("  Input: first row binary group names, first column ORF_IDs")
    message("  Output: tab delimited (ORF_ID, logFC, logCPM, PValue, FDR)")

} else {
    library("edgeR")
    
    # input counts (skip first row)
    dat = read.table(infile, sep="\t", header=F, comment='', quote='', skip=1)
    x.counts = dat[,-1]
    rownames(x.counts) = dat[,1]
    
    # input binary group names (first row)
    dat = read.table(infile, sep="\t", header=F, comment='', quote='', nrows=1, stringsAsFactors=F)
    x.group = factor(as.character(dat[1,-1]))
    x.group.summary = summary(x.group)
    
    if(length(x.group.summary) == 2 && max(x.group.summary) > 1) {
        # simple single-factor group edgeR
        y=DGEList(counts=x.counts, group=x.group)
        y=calcNormFactors(y)
        y=estimateCommonDisp(y)
        y=estimateTagwiseDisp(y)
        et=exactTest(y)
        FDR=p.adjust(et$table$PValue,method="BH")
        
        # write table with proper column headers (row.names=F)
        res=data.frame(rownames(et$table), et$table, FDR)
        names(res)[1] = 'id'
        write.table(res, file=outfile, sep="\t", quote=F, row.names=F, col.names=T)
    
    } else {
        stop("First row of input must specify exactly 2 groups, at least one of which has replicates")
    }
}
