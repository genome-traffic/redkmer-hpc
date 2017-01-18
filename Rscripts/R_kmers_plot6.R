#!/usr/bin/env Rscript
library (ggplot2)
install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(kmer<-fread(paste(Rworkdir,"/kmers/dataforplotting/kmer_results_plot6.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

g6 <- ggplot(kmer) + geom_point(aes(x=log10sum, y=CQ, color=selection),alpha=0.05, size=0.2)+
  scale_color_manual(values=c("grey","red2"))+
  ylim(0,5)+
  theme_bw()
ggsave((paste(Rworkdir,"/plots/kmer_analysis_6.png",sep="")),width=13, height=10)
