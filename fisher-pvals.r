#!/usr/bin/env Rscript
#
# Fisher Exact Test p-values from 2x2 contingency table
#
args <- commandArgs(TRUE)
infile = paste("", args[1], sep="")
outfile = paste("", args[2], sep="")
if(nchar(infile) >= 1 && !infile == "NA" && nchar(outfile) >= 1 && !outfile == "NA") {
    x = read.table(infile, sep="\t", header=F)
    dx = data.matrix(x)
    n = dim(dx)[1]
    if(n >= 1) {
        p = rep(1, n)
        for(i in 1:n) {d=matrix(dx[i,],nrow=2); p[i]=fisher.test(d, alternative = "greater",conf.int=F)$p}
        fdr = p.adjust(p)
        dxp = data.frame(dx,p,fdr)
        names(dxp) = c("a","b","c","d","p-value","fdr")
        if(nchar(outfile) >= 1) {
            write.table(dxp, outfile, quote=F, sep="\t", row.names=F, col.names=T)
        } else {
            print(dxp)
        }
    }
} else {
    warning("Usage: fisher-pvals.r [input table (a,b,c,d)] [output table (a,b,c,d,p-value,fdr)]")
}
