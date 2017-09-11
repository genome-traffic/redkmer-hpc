library (ggplot2)
library (data.table)
library (RColorBrewer)
library(plyr)
library(ggrepel)


#plotting for redkmer paper

pacbio<-read.table("[path/to/file]/Redkmer_data/pacBio_MappedReads.txt", header=T, sep="\t")
pacbio$bin[pacbio$CQ>=1.5]<-"X"
pacbio$bin[pacbio$CQ<1.5]<-"A"
pacbio$bin[pacbio$CQ<0.3]<-"Y"
pacbio$bin[pacbio$CQ>=2.5]<-"GA"
pacbio$bin<-as.factor(pacbio$bin)
pacbio$bin <- factor(pacbio$bin,levels = c("A","X","Y","GA"),ordered = TRUE)

g1<-ggplot(pacbio)+
  geom_bar(aes(x=reorder(bin,bin,function(x)+length(x)),fill=bin),color="black")+
  theme_bw(base_size=15)+
  scale_fill_manual(name="", values=c("springgreen4","red2","dodgerblue2","grey"), labels=c("A-bin", "X-bin", "Y-bin", "GA-bin" ))+
  scale_x_discrete(name="Chromosome bin")+
  scale_y_continuous(name="number of reads")+
  theme(legend.position="top")+
  coord_flip()
  ggsave("[path/to/file]/Figure2A.tiff",width=8, height=4)

   
  # function for mean labels
  mean.n <- function(x){
    return(c(y = -2, label = round(median(x),2))) 
    # experiment with the multiplier to find the perfect position
  }  

  
  
g2 <-ggplot(pacbio,aes(x=bin,y=log10(LSum)))+
    geom_boxplot(aes(fill=bin))+
    scale_fill_manual(name="", values=c("springgreen4","red2","dodgerblue2","grey"), labels=c("A-bin", "X-bin", "Y-bin", "GA-bin" ))+
    theme_bw(base_size=15)+
    theme(legend.position="none")+
    scale_y_continuous(name = "log10(LSum)")+
    scale_x_discrete(name = "Chromosome bin",limits = rev(levels(pacbio$bin)))+
    guides(color = guide_legend(override.aes = list(size=10,alpha=1)))+
    coord_flip()
  ggsave("[path/to/file]/Figure2C.png",width=8, height=4)
  
  
g3 <- ggplot() + 
    geom_point(data=pacbio,aes(x=log10(LSum), y=CQ,color=bin),alpha=0.1,size=0.2)+
    scale_color_manual(name="", values=c("springgreen4","red2","dodgerblue2","grey"), labels=c("A-bin", "X-bin", "Y-bin", "GA-bin" ))+
    guides(color = guide_legend(override.aes = list(size=10,alpha=1)))+
    theme_bw(base_size=15)+
    theme(legend.position="top")+
    scale_y_continuous(name = "CQ", limits=c(0,5))+
    scale_x_continuous(name = "log10(LSum)")
ggsave("[path/to/file]/Figure2B.png",width=8, height=8)
