#!/usr/bin/env Rscript
library (ggplot2)
#install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(kmer<-fread(paste(Rworkdir,"/kmers/dataforplotting/kmer_results_plot2.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

g2<- ggplot(kmer)+geom_density(aes(x=log10sum))+
  theme_bw(base_size=21)+
  scale_y_continuous(name = "kmer density")+
  scale_x_continuous(name = "log10(sum)")
ggsave((paste(Rworkdir,"/plots/redkmer_plot_kmers_2.png",sep="")),width=13, height=13)
