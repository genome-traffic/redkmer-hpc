#!/usr/bin/env Rscript
library (ggplot2)
install.packages("data.table", repos="http://cran.r-project.org")
library (data.table)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

system.time(kmer<-fread(paste(Rworkdir,"/kmers/kmer_results.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE))

#system.time(kmer<-fread("~/Dropbox/UNIPG/Projets/Universal_X_shredder/software/redkmer/simulateddatasets/complex/plots/kmer_results.txt", header=T, sep="\t",stringsAsFactors=FALSE))

kmer$candidate[kmer$CQ>=xmin]<-"X"
kmer$candidate[kmer$CQ<xmin]<-"A"
kmer$candidate[kmer$CQ<ymax]<-"Y"
kmer$candidate[kmer$CQ>=xmax]<-"GA"
kmer$label<-kmer$hits_threshold
kmer$label[kmer$sum_offtargets>0]<-"offtargets"
kmer$candidate<-as.factor(kmer$candidate)

kmer$hits_threshold<-as.factor(kmer$hits_threshold)
summary(kmer$hits_threshold)
summary(kmer$CQ)
summary(kmer$offtargets)
summary(kmer$sum)

kmersX<-subset(kmer,kmer$hits_threshold=="pass")
selectSum<-as.numeric(quantile(kmersX$sum,c(.995)))
kmer$selection<-"bad candidates"
kmer$selection[kmer$sum>selectSum & kmer$CQ>1.5 & kmer$hits_threshold=="pass"]<-"good kmers"
kmer$selection<-as.factor(kmer$selection)

candidateXkmers<-subset(kmer,kmer$selection=="good kmers")
candidateXkmersSeq<-subset(candidateXkmers,select=c(1,2))
write.table(candidateXkmers,file=(paste(Rworkdir,"/kmers/candidateXkmers.txt",sep="")),sep="\t",row.names = F,quote=F,col.names=F)
write.table(candidateXkmersSeq,file=(paste(Rworkdir,"/kmers/candidateXkmers.seq",sep="")),sep="\t",row.names = F,quote=F,col.names=F)



g1<- ggplot(kmer)+geom_density(aes(x=(CQ)))+
  theme_bw()
ggsave((paste(Rworkdir,"/plots/kmer_analysis_1.png",sep="")),width=13, height=10)

g2<- ggplot(kmer)+geom_density(aes(x=log10(sum)))+
  theme_bw()
ggsave((paste(Rworkdir,"/plots/kmer_analysis_2.png",sep="")),width=13, height=10)

g3 <- ggplot(kmer) + geom_point(aes(x=log10(sum), y=CQ,color=candidate),alpha=0.4)+
  scale_color_manual(values=c("springgreen4","black","red2","dodgerblue2"))+
  theme_bw()+
  ylim(0,5)
ggsave((paste(Rworkdir,"/plots/kmer_analysis_3.png",sep="")),width=13, height=10)

g4 <- ggplot(kmer) + geom_point(aes(x=log10(sum), y=CQ,color=hits_threshold),alpha=0.8)+
  scale_color_manual(values=c("grey","black","red"))+
  ylim(0,5)+
  theme_bw()
ggsave((paste(Rworkdir,"/plots/kmer_analysis_4.png",sep="")),width=13, height=10)

g5 <- ggplot(kmer) + geom_point(aes(x=log10(sum), y=CQ,color=label),alpha=0.8)+
  scale_color_manual(values=c("grey","black","blue","red"))+
  ylim(0,5)+
  theme_bw()
ggsave((paste(Rworkdir,"/plots/kmer_analysis_5.png",sep="")),width=13, height=10)

g6 <- ggplot(kmer) + geom_point(aes(x=log10(sum), y=CQ, color=selection),alpha=0.8)+
  scale_color_manual(values=c("grey","red2"))+
  ylim(0,5)+
  theme_bw()
ggsave((paste(Rworkdir,"/plots/kmer_analysis_6.png",sep="")),width=13, height=10)

g7 <- ggplot(kmer)+
  geom_point(aes(x=sum,y=offtargets,color=hits_threshold))+
  theme_bw()
ggsave((paste(Rworkdir,"/plots/kmer_analysis_7.png",sep="")),width=13, height=10)

