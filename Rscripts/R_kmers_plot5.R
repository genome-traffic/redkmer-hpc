#!/usr/bin/env Rscript
library (ggplot2)
#install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(kmer<-fread(paste(Rworkdir,"/kmers/dataforplotting/kmer_results_plot5.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

dim(kmer)

kmer$label<-as.factor(kmer$label)
summary(kmer$label)
summary(kmer$CQ)
summary(kmer$log10sum)

g5 <- ggplot(kmer) + geom_point(aes(x=log10sum, y=CQ,color=label),alpha=0.05, size=0.2)+
  scale_color_manual(values=c("grey","black","blue","red"))+
  ylim(0,5)+
  theme_bw()
ggsave((paste(Rworkdir,"/plots/kmer_analysis_5.png",sep="")),width=13, height=10)


g6 <- ggplot() + geom_point(data=subset(kmer,kmer$label!="nohits"), aes(x=log10sum, y=CQ,color=label),alpha=0.05, size=0.2)+
  scale_color_manual(values=c("blue","red"))+
  ylim(0,5)+
  theme_bw()+
  facet_grid(.~label)+
  ggtitle('presence of off-targets - not used for selection') 
ggsave((paste(Rworkdir,"/plots/kmer_analysis_5_2.png",sep="")),width=13, height=10)
