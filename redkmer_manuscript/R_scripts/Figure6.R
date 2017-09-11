library (ggplot2)
library (data.table)
library (RColorBrewer)
library(plyr)
library(ggrepel)


pacbio<-read.table("[path/to/file]/pacBio_MappedReads.txt", header=T, sep="\t")
pacbio$bin[pacbio$CQ>=1.5]<-"X"
pacbio$bin[pacbio$CQ<1.5]<-"A"
pacbio$bin[pacbio$CQ<0.3]<-"Y"
pacbio$bin[pacbio$CQ>=2.5]<-"GA"
pacbio$bin<-as.factor(pacbio$bin)

summary(pacbio$bin)

g3 <- ggplot() + 
  geom_point(data=pacbio,aes(x=log10(LSum), y=CQ,color=bin),alpha=0.1,size=0.2)+
  scale_color_manual(name="", values=c("A"="springgreen4","GA"="grey","X"="red2","Y"="dodgerblue2"), labels=c("A-bin", "X-bin", "Y-bin", "GA-bin" ))+
  guides(color = guide_legend(override.aes = list(size=5,alpha=1)))+
  theme_bw(base_size=15)+
  theme(legend.position="top")+
  scale_y_continuous(name = "CQ", limits=c(0,5))+
  scale_x_continuous(name = "log10(LSum)")
ggsave("[path/to/file]/Figure6A.png",width=8, height=8)


rdnakmers<-fread(paste(Rworkdir,"/refgenes/kmers_rdna.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE)
kmer<-fread(paste(Rworkdir,"/kmers/dataforplotting/kmer_results_plot6.txt", sep=""), header=T, sep="\t",stringsAsFactors=FALSE)

dim(kmer)
summary(kmer$selection)
summary(kmer$CQ)
summary(kmer$log10sum)

kmer <- subset(kmer, kmer$log10sum >= minlog10sum)
kmer2 <- merge(kmer, rdnakmers, by="kmer_id", all=TRUE)



g6.1 <- ggplot()+ 
  geom_point(data=subset(kmer2,kmer2$selection=="badKmers"), aes(x=log10sum, y=CQ, color=selection),alpha=0.05, size=0.2)+
  geom_point(data=subset(kmer2,kmer2$selection=="goodKmers"), aes(x=log10sum, y=CQ, color=selection),alpha=0.5, size=0.5)+
  geom_point(data=subset(kmer2,kmer2$locus=="rDNA"),aes(x=log10sum, y=CQ), color="blue", alpha=0.5, size=0.5)+
  scale_color_manual(name="", values=c("grey33","red"), labels=c("unsuitable kmers", "candidate kmers"))+
  guides(color = guide_legend(override.aes = list(size=5,alpha=1)))+
  theme_bw(base_size=15)+
  theme(legend.position="top")+
  scale_y_continuous(name = "CQ", limits=c(0,5))+
  scale_x_continuous(name = "log10(sum)")
ggsave("[path/to/file]/Figure6B.png",width=8, height=8)

