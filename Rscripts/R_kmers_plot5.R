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

kmer <- subset(kmer, kmer$log10sum >= minlog10sum)

g5 <- ggplot() + geom_point(data=subset(kmer,kmer$label!="nohits"), aes(x=log10sum, y=CQ,color=label),alpha=0.05, size=0.2)+
  scale_color_manual(name="", values=c("blue","red"), labels=c("Perfect hit to non-X bin", "X-specific"))+
  theme_bw(base_size=21)+
  theme(legend.position="top")+
  guides(color = guide_legend(override.aes = list(size=5,alpha=1)))+
  facet_grid(label~.)+
  scale_y_continuous(name = "CQ",limits=c(0,5))+
  scale_x_continuous(name = "log10(sum)")
ggsave((paste(Rworkdir,"/plots/redkmer_plot_kmers_5.png",sep="")),width=13, height=13)
