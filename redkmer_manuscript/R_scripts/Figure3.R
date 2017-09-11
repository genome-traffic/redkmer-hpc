library (ggplot2)
library (data.table)
library (RColorBrewer)
library(plyr)
library(ggrepel)

#bring in blast2 results containing the masked genome
blast2<-read.table("[path/to/file]/blast_vs_maskedgenome.blast", header=T, sep="\t")
#fix bad naming
levels(blast2$chromosome)[levels(blast2$chromosome)=="2a"] <- "2R"
levels(blast2$chromosome)[levels(blast2$chromosome)=="Y_unplaced"] <- "Y"
levels(blast2$chromosome)[levels(blast2$chromosome)=="UNKN"] <- "UN"
levels(blast2$bin_id)
levels(blast2$bin_id)[levels(blast2$bin_id)=="Xbin"] <- "Xbin-masked"

blast<-read.table("[path/to/file]/blast_vs_genome.blast", header=T, sep="\t")
#fix bad naming
levels(blast$chromosome)[levels(blast$chromosome)=="2a"] <- "2R"
levels(blast$chromosome)[levels(blast$chromosome)=="Y_unplaced"] <- "Y"
levels(blast$chromosome)[levels(blast$chromosome)=="UNKN"] <- "UN"

#bring in coordinates
coordinates<-read.table("[path/to/file]/genome.coordinates", header=T, sep="\t")


blast3<-subset(blast,blast$chromosome!="Mt")


g1<-ggplot()+
  geom_rect(data=subset(coordinates,coordinates$chromosome!="Mt") ,aes(xmin=start, xmax=end, ymin=0, ymax=2.5),color="black",fill="white",size=0.2)+
  geom_rect(data=subset(blast2,blast2$bin_id=="Xbin-masked"),aes(xmin=s.start,xmax=s.end, ymin=2,ymax=2.5,fill=bin_id))+
  geom_rect(data=subset(blast3,blast3$bin_id=="Abin"),aes(xmin=s.start,xmax=s.end, ymin=1,ymax=1.5,fill=bin_id))+
  geom_rect(data=subset(blast3,blast3$bin_id=="Xbin"),aes(xmin=s.start,xmax=s.end, ymin=1.5,ymax=2,fill=bin_id))+
  geom_rect(data=subset(blast3,blast3$bin_id=="Ybin"),aes(xmin=s.start,xmax=s.end, ymin=0.5,ymax=1,fill=bin_id))+
  geom_rect(data=subset(blast3,blast3$bin_id=="GAbin"),aes(xmin=s.start,xmax=s.end, ymin=0,ymax=0.5,fill=bin_id))+
  facet_grid(chromosome~.)+
  scale_fill_manual(name="",values=c("Abin"="springgreen3","GAbin"="black","Xbin"="red2","Ybin"="dodgerblue2","Xbin-masked"="tomato1"))+
  guides(color = guide_legend(override.aes = list(size=5,alpha=1)))+
  theme_classic(base_size=15)+
  theme(axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        legend.position="top",
        panel.spacing.y =unit(.05, "lines"),
        strip.background = element_rect(size=0.2),
        strip.text.y = element_text(size=10),
        axis.line = element_blank())+
  scale_x_continuous(name="Position in Mbp",labels=c(0,2,4,6))
ggsave("[path/to/file]/Figure3.png",width=8, height=5)

