#!/usr/bin/env Rscript
library (ggplot2)
#install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(kmer<-fread(paste(Rworkdir,"/kmers/dataforplotting/kmer_results_plot3.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

kmer <- subset(kmer, kmer$log10sum >= minlog10sum)

g3 <- ggplot(kmer) + geom_point(aes(x=log10sum, y=CQ,color=candidate),alpha=0.05, size=0.2)+
  scale_color_manual(values=c("springgreen4","black","red2","dodgerblue2"))+
  theme_bw()+
  ylim(0,5)
ggsave((paste(Rworkdir,"/plots/kmer_analysis_3.png",sep="")),width=13, height=10)
