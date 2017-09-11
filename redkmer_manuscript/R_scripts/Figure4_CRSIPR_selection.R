library (ggplot2)
library (data.table)
library (RColorBrewer)
library(plyr)
library(ggrepel)


#candidateXkmers.txt is the output file of redkmer
#candCas9.output.scored and candCpf1.output.scored are the output files of FlashFry (https://github.com/aaronmck/FlashFry)


kmers<-read.table("[path/to/file]/candidateXkmers.txt", header=T, sep="\t")
cas<-read.table("[path/to/file]/candCas9.output.scored", header=T, sep="\t")
cpf<-read.table("[path/to/file]/candCpf1.output.scored", header=T, sep="\t")

target<-merge(cas,cpf,by="kmer_id",all=TRUE)
v<-merge(kmers,target,by="kmer_id",all=TRUE)
v$cas<-0
v$cpf<-0
v <- within(v,
            cas <- ifelse(!is.na(otCount.x), 1, 0))
v <- within(v,
            cpf <- ifelse(!is.na(otCount.y), 2,0))
v$targetable<-v$cpf+v$cas

v$targetable[v$targetable==0]<-"none"
v$targetable[v$targetable==1]<-"Cas9"
v$targetable[v$targetable==2]<-"CPF1"
v$targetable[v$targetable==3]<-"Cas9 & CPF1"
v$targetable<-as.factor(v$targetable)
summary(v$targetable)

ggplot()+
  geom_point(data=subset(v,v$targetable=="none"),aes(x=log10sum,y=log10(hits_sum),color=targetable),alpha=0.2, size=0.3)+
  geom_point(data=subset(v,v$targetable=="Cas9"),aes(x=log10sum,y=log10(hits_sum),color=targetable),alpha=0.5, size=0.5)+
  geom_point(data=subset(v,v$targetable=="CPF1"),aes(x=log10sum,y=log10(hits_sum),color=targetable),alpha=0.5, size=0.5)+
  geom_point(data=subset(v,v$targetable=="Cas9 & CPF1"),aes(x=log10sum,y=log10(hits_sum),color=targetable),alpha=0.5, size=0.5)+
  scale_color_manual(name="",values=c("none"="grey","Cas9"="red2","CPF1"="dodgerblue2","Cas9 & CPF1"="gold"))+
  theme_bw(base_size=15)+
  theme(legend.position=c(0.85,0.3))+
  guides(color = guide_legend(override.aes = list(size=5,alpha=1)))+
  scale_y_continuous(name = "log10(Hits_Sum)")+
  scale_x_continuous(name = "log10(Sum)")
ggsave("[path/to/file]/CRISPRable.png",width=8, height=8)


ggplot(subset(v,v$targetable!="none"))+
  geom_bar(aes(x=reorder(targetable,targetable,function(x)-length(x)),fill=targetable),color="black")+
  theme_bw(base_size=15)+
  scale_fill_manual(name="",values=c("Cas9"="red2","CPF1"="dodgerblue2","Cas9 & CPF1"="gold"))+
  scale_x_discrete(name="")+
  scale_y_continuous(name="number of kmers")+
  theme(legend.position="none")
ggsave("[path/to/file]/CRISPRable2.png",width=8, height=8)

