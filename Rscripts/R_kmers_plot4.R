#!/usr/bin/env Rscript
library (ggplot2)
#install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(kmer<-fread(paste(Rworkdir,"/kmers/dataforplotting/kmer_results_plot4.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

dim(kmer)
summary(kmer$hits_threshold)
summary(kmer$CQ)
summary(kmer$log10sum)


g4 <- ggplot(kmer) + geom_point(aes(x=log10sum, y=CQ,color=hits_threshold),alpha=0.05, size=0.2)+
  scale_color_manual(values=c("grey","black","red"))+
  ylim(0,5)+
  theme_bw()
ggsave((paste(Rworkdir,"/plots/kmer_analysis_4.png",sep="")),width=13, height=10)


g5 <- ggplot(kmer) + geom_point(aes(x=log10sum, y=CQ,color=hits_threshold),alpha=0.05, size=0.2)+
  scale_color_manual(values=c("grey","black","red"))+
  ylim(0,5)+
  theme_bw()+
  facet_grid(.~hits_threshold)+
  ggtitle('XSI threshold based selection') 
ggsave((paste(Rworkdir,"/plots/kmer_analysis_4_2.png",sep="")),width=13, height=10)
