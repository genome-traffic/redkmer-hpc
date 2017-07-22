#!/usr/bin/env Rscript
library (ggplot2)
#install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(kmer<-fread(paste(Rworkdir,"/kmers/dataforplotting/kmer_results_plot7.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

kmer <- subset(kmer, kmer$log10sum >= minlog10sum)

g7 <- ggplot(kmer)+
geom_point(aes(x=log10sum,y=log10(hits_sum),color=selection),alpha=0.05, size=0.2)+
scale_color_manual(name="", values=c("grey33","red"), labels=c("unsuited kmers", "candidate kmers"))+
theme_bw(base_size=21)+
theme(legend.position="top")+
guides(color = guide_legend(override.aes = list(size=5,alpha=1)))+
scale_y_continuous(name = "log10(Hits_Sum)")+
scale_x_continuous(name = "log10(Sum)")
ggsave((paste(Rworkdir,"/plots/redkmer_plot_kmers_7.png",sep="")),width=13, height=13)
