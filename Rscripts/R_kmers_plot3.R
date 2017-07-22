#!/usr/bin/env Rscript
library (ggplot2)
#install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(kmer<-fread(paste(Rworkdir,"/kmers/dataforplotting/kmer_results_plot3.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

kmer <- subset(kmer, kmer$log10sum >= minlog10sum)

g3 <- ggplot(kmer) + geom_point(aes(x=log10sum, y=CQ,color=candidate),alpha=0.05, size=0.2)+
  scale_color_manual(name="", values=c("springgreen4","black","red2","dodgerblue2"), labels=c("A-kmer", "GA-kmer", "X-kmer", "Y-kmer" ))+
  guides(color = guide_legend(override.aes = list(size=5,alpha=1)))+
  theme_bw(base_size=21)+
  theme(legend.position="top")+
  scale_y_continuous(name = "CQ", limits=c(0,5))+
  scale_x_continuous(name = "log10(sum)")
ggsave((paste(Rworkdir,"/plots/redkmer_plot_kmers_3.png",sep="")),width=13, height=13)
