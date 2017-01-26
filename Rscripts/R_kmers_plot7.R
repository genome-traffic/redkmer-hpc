#!/usr/bin/env Rscript
library (ggplot2)
#install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(kmer<-fread(paste(Rworkdir,"/kmers/dataforplotting/kmer_results_plot7.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

g7 <- ggplot(kmer)+
  geom_point(aes(x=log10sum,y=offtargets,color=hits_threshold))+
  theme_bw()
ggsave((paste(Rworkdir,"/plots/kmer_analysis_7.png",sep="")),width=13, height=10)
