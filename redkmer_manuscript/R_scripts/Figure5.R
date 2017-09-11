library (ggplot2)
library (data.table)
library (RColorBrewer)
library(plyr)
library(ggrepel)
install.packages('svglite')

# bring in data of Xkmers
kmers<-read.table("[path/to/file]/candidateXkmers.txt", header=T, sep="\t")
blast<-read.table("[path/to/file]/candidateXkmers_vs_refgenes.blast", header=T, sep="\t")
colnames(blast)[colnames(blast) == 'queryid'] <- 'kmer_id'

kmbla<-merge(kmers,blast,by="kmer_id",all=TRUE)
levels(kmbla$chromosome)
kmbla$man<-kmbla$chromosome
levels(kmbla$man)[levels(kmbla$man)=="104184_DNA"] <- "rDNA"
levels(kmbla$man)[levels(kmbla$man)=="169706..115790_DNA"] <- "R6Ag1"
levels(kmbla$man)[levels(kmbla$man)=="177708..130922_DNA"] <- "rDNA"
levels(kmbla$man)[levels(kmbla$man)=="6058_transposon"] <- "R6Ag1"
levels(kmbla$man)[levels(kmbla$man)=="73333_DNA"] <- "Unk_Repeat"
levels(kmbla$man)[levels(kmbla$man)=="95130..22811_DNA"] <- "Tsessebe_I"
levels(kmbla$man)[levels(kmbla$man)=="Agam_AB090813_RTAg4_LINE_RTAG4"] <- "RTAg4"
levels(kmbla$man)[levels(kmbla$man)=="Agam_M93690_RT1_LINE_RT1"] <- "RT1"
levels(kmbla$man)[levels(kmbla$man)=="DMRG_DNA"] <- "rDNA"
levels(kmbla$man)[levels(kmbla$man)=="M93691.1"] <- "rDNA"
levels(kmbla$man)[levels(kmbla$man)=="R1Fam4_1_LINE_R1Fam4"] <- "R1"
levels(kmbla$man)[levels(kmbla$man)=="rDNA_sequenc.6995"] <- "rDNA"
levels(kmbla$man)[levels(kmbla$man)=="RT2_2_LINE_RT2"] <- "RT2"
levels(kmbla$man)[levels(kmbla$man)=="152069,22298..49677,24221..55237,68737..64729,147450..126626_DNA"] <- "Unk_Repeat"
levels(kmbla$man)[levels(kmbla$man)=="170429..51533_DNA"] <- "rDNA"
levels(kmbla$man)[levels(kmbla$man)=="190243..196983_DNA"] <- "RT61"
levels(kmbla$man)[levels(kmbla$man)=="67872..78296_DNA"] <- "RTAg4"
levels(kmbla$man)[levels(kmbla$man)=="94667..185337_DNA"] <- "rDNA"
levels(kmbla$man)[levels(kmbla$man)=="Agam_AB090812_RTAg3_LINE_RTAG3"] <- "RTAg3"
levels(kmbla$man)[levels(kmbla$man)=="Agam_AB090817_R6Ag1_LINE_R6Ag1"] <- "R6Ag1"
levels(kmbla$man)[levels(kmbla$man)=="Agam_M93691_RT2_LINE_RT2"] <- "RT2"
levels(kmbla$man)[levels(kmbla$man)=="KP666116.1"] <- "AgX367"
levels(kmbla$man)[levels(kmbla$man)=="R1Fam10_1_LINE_R1Fam10"] <- "R1"
levels(kmbla$man)[levels(kmbla$man)=="R2B_DM_LINE_R2"] <- "R2"
levels(kmbla$man)[levels(kmbla$man)=="RT1_LINE_R1"] <- "R1"
levels(kmbla$man)[levels(kmbla$man)=="X"] <- "X assembly"
kmbla$man<-as.character(kmbla$man)
kmbla$man[is.na(kmbla$man)] <- "Unknown"
kmbla$man<-as.factor(kmbla$man)



kmblaX<-subset(kmbla,kmbla$chromosome=="X")

colourCount = length(unique(kmbla$man))
getPalette = colorRampPalette(brewer.pal(11, "Paired"))


g1<-ggplot(kmbla)+
  geom_bar(aes(x=reorder(man,man,function(x)+length(x)),fill=man),color="black")+
  scale_x_discrete(name="")+
  scale_y_continuous(name="number of hits")+
  coord_flip()+
  theme_bw(base_size=15)+
  scale_fill_manual(values = getPalette(colourCount),guide=FALSE)
ggsave("[path/to/file]/Figure5A.png",width=8, height=8)


g2 <- ggplot()+
  geom_point(data=kmbla,aes(x=log10sum,y=log10(hits_sum)),alpha=0.05, size=0.2)+
  geom_point(data=subset(kmbla,kmbla$man!="X assembly" & kmbla$man!="Unknown") ,aes(x=log10sum,y=log10(hits_sum),color=man),alpha=0.2, size=0.2)+
  scale_color_manual(values = getPalette(colourCount),name="")+
  theme_bw(base_size=15)+
  theme(legend.position=c(0.85,0.3))+
  guides(color = guide_legend(override.aes = list(size=5,alpha=1)))+
  scale_y_continuous(name = "log10(Hits_Sum)")+
  scale_x_continuous(name = "log10(Sum)")
ggsave("[path/to/file]/Figure5B.png",width=8, height=8)





