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

kmer <- subset(kmer, kmer$log10sum >= minlog10sum)

g6 <- ggplot(kmer)+ 
geom_point(aes(x=log10sum, y=CQ,color=selection),alpha=0.05, size=0.2)+
scale_color_manual(name="", values=c("grey33","red"), labels=c("unsuitable kmers", "candidate kmers"))+
theme_bw(base_size=21)+
theme(legend.position="top")+
guides(color = guide_legend(override.aes = list(size=5,alpha=1)))+
facet_grid(selection~.)+
scale_y_continuous(name = "CQ",limits=c(0,5))+
scale_x_continuous(name = "log10(sum)")
ggsave((paste(Rworkdir,"/plots/redkmer_plot_kmers_6.1.png",sep="")),width=13, height=13)

g6.1 <- ggplot()+ 
geom_point(data=subset(kmer,kmer$selection=="badKmers"), aes(x=log10sum, y=CQ),alpha=0.05, size=0.2,color="grey33")+
geom_point(data=subset(kmer,kmer$selection=="goodKmers"), aes(x=log10sum, y=CQ),alpha=0.09, size=0.4,color="red")+
theme_bw(base_size=21)+
scale_y_continuous(name = "CQ", limits=c(0,5))+
scale_x_continuous(name = "log10(sum)")
ggtitle('Candidate kmers - red kmers are X-shredding candidates') 
ggsave((paste(Rworkdir,"/plots/redkmer_plot_kmers_6.2.png",sep="")),width=10, height=10)



