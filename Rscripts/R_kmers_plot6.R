#!/usr/bin/env Rscript
library (ggplot2)
#install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(kmer<-fread(paste(Rworkdir,"/kmers/dataforplotting/kmer_results_plot6.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

dim(kmer)
summary(kmer$selection)
summary(kmer$CQ)
summary(kmer$log10sum)

g6 <- ggplot(kmer) + geom_point(aes(x=log10sum, y=CQ, color=selection),alpha=0.05, size=0.2)+
  scale_color_manual(values=c("grey","red2"))+
  ylim(0,5)+
  theme_bw()
ggsave((paste(Rworkdir,"/plots/kmer_analysis_6.png",sep="")),width=13, height=10)


g7 <- ggplot()+ 
geom_point(data=subset(kmer,kmer$selection=="badKmers"), aes(x=log10sum, y=CQ),alpha=0.05, size=0.2,color="grey33")+
geom_point(data=subset(kmer,kmer$selection=="goodKmers"), aes(x=log10sum, y=CQ),alpha=0.09, size=0.4,color="red")+
ylim(0,5)+
theme_bw()+
ggtitle('Candidate kmers - red kmers are X shredding candidates') 
ggsave((paste(Rworkdir,"/plots/kmer_analysis_6_1.png",sep="")),width=13, height=10)


g8 <- ggplot(kmer)+ 
geom_point(aes(x=log10sum, y=CQ,color=selection),alpha=0.05, size=0.2)+
scale_color_manual(values=c("grey33","red"))+
ylim(0,5)+
theme_bw()+
facet_grid(.~selection)+
ggtitle('Candidate kmers - red kmers are X shredding candidates') 
ggsave((paste(Rworkdir,"/plots/kmer_analysis_6_2.png",sep="")),width=13, height=10)

