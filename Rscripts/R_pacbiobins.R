#!/usr/bin/env Rscript
library (ggplot2)
library(MASS)
source("redkmer.cfg.R")
setwd(dirname(Rworkdir))

pacbio<-read.table(paste(Rworkdir,"/pacBio_illmapping/pacBio_MappedReads.txt",sep=""), header=T, sep="\t")

pacbio$bin[pacbio$CQ>=xmin]<-"X"
pacbio$bin[pacbio$CQ<xmin]<-"A"
pacbio$bin[pacbio$CQ<ymax]<-"Y"
pacbio$bin[pacbio$CQ>=xmax]<-"GA"
pacbio$bin<-as.factor(pacbio$bin)

summary(pacbio$bin)
summary(pacbio$LSum)
summary(pacbio$bp)

# make some plots

g1 <- ggplot() + 
  geom_point(data=pacbio,aes(x=log10(LSum), y=CQ,color=bin),alpha=0.1,size=0.2)+
  scale_color_manual(name="", values=c("springgreen4","black","red2","dodgerblue2"), labels=c("A-bin", "GA-bin", "X-bin", "Y-bin" ))+
  guides(color = guide_legend(override.aes = list(size=5,alpha=1)))+
  theme_bw(base_size=21)+
  theme(legend.position="top")+
  scale_y_continuous(name = "CQ", limits=c(0,5))+
  scale_x_continuous(name = "log10(LSum)")
plot(g1)
ggsave(paste(Rworkdir,"/plots/redkmer_plot_reads_1.png",sep=""),width=13, height=13)

g2<- ggplot(pacbio)+geom_histogram(aes(x=CQ),binwidth = 0.05)+
  theme_bw(base_size=21)+
  scale_y_continuous(name = "number of long reads")+
  scale_x_continuous(name = "CQ", limits=c(0,5))
plot(g2)
ggsave(paste(Rworkdir,"/plots/redkmer_plot_reads_2.png",sep=""),width=13, height=13)

g3<- ggplot(pacbio)+
  geom_histogram(aes(x=log10(Sum)),binwidth = 0.1)+
  theme_bw(base_size=21)+
  scale_y_continuous(name = "number of long reads")+
  scale_x_continuous(name = "log10(Sum)")
  plot(g3)
ggsave(paste(Rworkdir,"/plots/redkmer_plot_reads_3.png",sep=""),width=13, height=13)

g4<- ggplot(pacbio)+
  geom_histogram(aes(x=log10(LSum)),binwidth = 0.1)+
  theme_bw(base_size=21)+
  scale_y_continuous(name = "number of long reads")+
  scale_x_continuous(name = "log10(LSum)")
plot(g4)
ggsave(paste(Rworkdir,"/plots/redkmer_plot_reads_4.png",sep=""),width=13, height=13)

g5<- ggplot(pacbio)+
  geom_histogram(aes(x=bp),binwidth = 100)+
  theme_bw(base_size=21)+
  scale_y_continuous(name = "number of long reads")+
  scale_x_continuous(name = "length in bp")
plot(g5)
ggsave(paste(Rworkdir,"/plots/redkmer_plot_reads_5.png",sep=""),width=13, height=13)

# function for mean labels
mean.n <- function(x){
  return(c(y = -200000, label = round(median(x),2))) 
  # experiment with the multiplier to find the perfect position
} 

# function for mean labels
mean.n <- function(x){
  return(c(y = -2, label = round(median(x),2))) 
  # experiment with the multiplier to find the perfect position
}  

g6 <-ggplot(pacbio,aes(x=bin,y=log2(LSum)))+
  geom_boxplot(aes(fill=bin))+
  stat_summary(fun.data = mean.n, geom = "text", fun.y = median,size=10)+
  scale_fill_manual(name="", values=c("springgreen4","black","red2","dodgerblue2"), labels=c("A-bin", "GA-bin", "X-bin", "Y-bin" ))+
  theme_bw(base_size=21)+
  theme(legend.position="top")+
  scale_y_continuous(name = "log2(LSum)")+
  scale_x_discrete(name = "Chromosomal Bin")+
  guides(color = guide_legend(override.aes = list(size=8,alpha=1)))
plot(g6)
ggsave(paste(Rworkdir,"/plots/redkmer_plot_reads_6.png",sep=""),width=13, height=13)

g7 <- ggplot(data=pacbio,aes(x=log10(LSum), y=CQ,color=bin))+ylim(0,5)+
	geom_point(alpha=0.025,size=0.1) +
	stat_density2d(aes(group = bin),geom="contour", bins=10,color="black",line=0.5)+
    scale_color_manual(name="", values=c("springgreen4","black","red2","dodgerblue2"), labels=c("A-bin", "GA-bin", "X-bin", "Y-bin" ))+
    theme_bw(base_size=21)+
    theme(legend.position="top")+
  guides(color = guide_legend(override.aes = list(size=5,alpha=1)))+
  	scale_y_continuous(name = "CQ", limits=c(0,5))+
    scale_x_continuous(name = "log10(LSum)")
plot(g7)
ggsave(paste(Rworkdir,"/plots/redkmer_plot_reads_7.png",sep=""),width=13, height=13)




