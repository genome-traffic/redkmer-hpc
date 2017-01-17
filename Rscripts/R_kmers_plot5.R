#!/usr/bin/env Rscript
library (ggplot2)
install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(kmer<-fread(paste(Rworkdir,"/kmers/dataforplotting/kmer_results_plot5.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

g5 <- ggplot(kmer) + geom_point(aes(x=log10sum, y=CQ,color=label),alpha=0.8)+
  scale_color_manual(values=c("grey","black","blue","red"))+
  ylim(0,5)+
  theme_bw()
ggsave((paste(Rworkdir,"/plots/kmer_analysis_5.png",sep="")),width=13, height=10)
