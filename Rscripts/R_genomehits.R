#!/usr/bin/env Rscript
library (ggplot2)
install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(blast<-fread(paste(Rworkdir,"/kmers/Refgenome_blast/blast_vs_genome.blast", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))
system.time(coordinates<-fread(paste(Rworkdir,"/kmers/Refgenome_blast/genome.coordinates", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

g1<-ggplot()+
  geom_rect(data=coordinates,aes(xmin=start, xmax=end, ymin=0, ymax=1),alpha=0.5,color="black",fill="white")+
  geom_rect(data=subset(blast,blast$bin_id!="Xkmers"),aes(xmin=s.start,xmax=s.end, ymin=0,ymax=1,fill=bin_id),alpha=0.1)+
  geom_jitter(data=subset(blast,blast$bin_id=="Xkmers"),aes(x=s.start, y=0.5),color="black",alpha=0.5,size=0.8,shape=21)+
  facet_grid(chromosome~.)+
  scale_fill_manual(values=c("Abin"="springgreen3","GAbin"="black","Xbin"="red2","Ybin"="dodgerblue2"))+
  theme_classic()+
  theme(axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank())
ggsave((paste(Rworkdir,"/plots/map_2_genome.png",sep="")),width=13, height=10)
