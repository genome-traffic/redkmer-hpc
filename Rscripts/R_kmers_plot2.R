#!/usr/bin/env Rscript
library (ggplot2)
install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(kmer<-fread(paste(Rworkdir,"/kmers/dataforplotting/kmer_results_plot2.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

g2<- ggplot(kmer)+geom_density(aes(x=log10sum))+
  theme_bw()
ggsave((paste(Rworkdir,"/plots/kmer_analysis_2.png",sep="")),width=13, height=10)
