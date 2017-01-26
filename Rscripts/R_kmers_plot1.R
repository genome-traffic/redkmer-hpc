#!/usr/bin/env Rscript
library (ggplot2)
#install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(kmer<-fread(paste(Rworkdir,"/kmers/dataforplotting/kmer_results_plot1.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

g1<- ggplot(kmer)+geom_density(aes(x=(CQ)))+
  theme_bw() + xlim(0, 5)
ggsave((paste(Rworkdir,"/plots/kmer_analysis_1.png",sep="")),width=13, height=10)
graphics.off()

