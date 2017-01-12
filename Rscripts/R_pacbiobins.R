#!/usr/bin/env Rscript
library (ggplot2)
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
g1 <- ggplot(pacbio) + geom_point(aes(x=Sum, y=CQ,color=bin),alpha=0.8)+
  scale_color_manual(values=c("springgreen4","black","red2","dodgerblue2"))+
  theme_bw()
plot(g1)
ggsave(paste(Rworkdir,"/plots/plot1_pacBIO_sum_CQ.png",sep=""))

g2 <- ggplot(pacbio) + geom_point(aes(x=log10(Sum), y=log2(CQ),color=bin),alpha=0.4)+
  scale_color_manual(values=c("springgreen4","black","red2","dodgerblue2"))+
  theme_bw()
plot(g2)
ggsave(paste(Rworkdir,"/plots/plot2_pacBIO_sum_CQ.png",sep=""))

g3 <- ggplot(pacbio) + geom_point(aes(x=log10(LSum), y=log2(CQ),color=bin),alpha=0.4)+
  scale_color_manual(values=c("springgreen4","black","red2","dodgerblue2"))+
  theme_bw()
plot(g3)
ggsave(paste(Rworkdir,"/plots/plot3_pacBIO_LSum_CQ.png",sep=""))

g4<- ggplot(pacbio)+geom_histogram(aes(x=CQ),binwidth = 0.05)+
  xlim(0,5)+
  theme_bw()
plot(g4)
ggsave(paste(Rworkdir,"/plots/plot4_pacBIO_CQ.png",sep=""))

g5<- ggplot(pacbio)+
  geom_histogram(aes(x=log10(Sum)),binwidth = 0.1)+
  theme_bw()
plot(g5)
ggsave(paste(Rworkdir,"/plots/plot5_pacBIO_log10Sum.png",sep=""))

g6<- ggplot(pacbio)+
  geom_histogram(aes(x=log10(LSum)),binwidth = 0.1)+
  theme_bw()
plot(g6)
ggsave(paste(Rworkdir,"/plots/plot6_pacBIO_log10LSum.png",sep=""))

g7<- ggplot(pacbio)+
  geom_histogram(aes(x=bp),binwidth = 100)+
  theme_bw()
plot(g7)
ggsave(paste(Rworkdir,"/plots/plot7_pacBIO_readlength.png",sep=""))

g8 <- ggplot() + 
  geom_point(data=pacbio,aes(x=log10(LSum), y=CQ,color=bin),alpha=0.8)+
  geom_density(data=subset(pacbio,pacbio$bin=="X"),aes(x=log10(LSum)),size=2,color="brown")+
  geom_density(data=subset(pacbio,pacbio$bin=="A"),aes(x=log10(LSum)),size=2,color="black")+
  geom_density(data=subset(pacbio,pacbio$bin=="Y"),aes(x=log10(LSum)),size=2,color="blue")+
  scale_color_manual(values=c("springgreen4","black","red2","dodgerblue2"))+
  theme_bw()+ylim(0,5)
plot(g8)
ggsave(paste(Rworkdir,"/plots/plot8_pacBIO_sum_CQ_densities.png",sep=""))

# function for mean labels
mean.n <- function(x){
  return(c(y = -200000, label = round(median(x),2))) 
  # experiment with the multiplier to find the perfect position
} 

g9 <-ggplot(pacbio,aes(x=bin,y=(LSum)))+
  geom_boxplot(aes(fill=bin))+
  stat_summary(fun.data = mean.n, geom = "text", fun.y = median)+
  scale_fill_manual(values=c("springgreen4","white","red2","dodgerblue2"))
plot(g9)
ggsave(paste(Rworkdir,"/plots/plot9_pacBIO_boxplots_Sum.png",sep=""))


# function for mean labels
mean.n <- function(x){
  return(c(y = -2, label = round(median(x),2))) 
  # experiment with the multiplier to find the perfect position
}  

g10 <-ggplot(pacbio,aes(x=bin,y=log2(LSum)))+
  geom_boxplot(aes(fill=bin))+
  stat_summary(fun.data = mean.n, geom = "text", fun.y = median)+
  scale_fill_manual(values=c("springgreen4","white","red2","dodgerblue2"))
plot(g10)
ggsave(paste(Rworkdir,"/plots/plot10_pacBIO_boxplots_Sum.png",sep=""))

g11 <- ggplot() + 
  geom_point(data=pacbio,aes(x=log10(LSum), y=CQ,color=bin),alpha=0.05,size=0.05)+
  scale_color_manual(values=c("springgreen4","black","red2","dodgerblue2"))+
  theme_bw()+ylim(0,5)
plot(g11)
ggsave(paste(Rworkdir,"/plots/plot11_pacBIO_sum_CQ_densities.png",sep=""))

g12 <- ggplot() + 
  geom_point(data=pacbio,aes(x=log10(LSum), y=CQ,color=bin),alpha=0.1,size=0.1)+
  scale_color_manual(values=c("springgreen4","black","red2","dodgerblue2"))+
  theme_bw()+ylim(0,5)
plot(g12)
ggsave(paste(Rworkdir,"/plots/plot12_pacBIO_sum_CQ_densities.png",sep=""))




