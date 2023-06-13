#use the eigenvec file

install.packages("ggplot2")
library("ggplot2")
install.packages("ggrepel")
library("ggrepel")

setwd("/storage/PROJECTS/Rebecca/GenErodeResults/GenErode/results/historical/pca/")
ret_pca=read.table("Aporia_crataegi-GCA_912999735.1-softmasked.historical.merged.biallelic.fmissing0.1.eigenvec")
attach(ret_pca)


ggplot(ret_pca, aes(x=V3, y=V4))+ geom_point(size=2, shape=1)+  
  geom_text_repel(aes(label = ret_pca$V1), size = 3, max.overlaps = 15)+
  geom_point(aes(col=V1), size=2)
#  coord_cartesian(ylim=c(-0.3, 0.4), xlim=c(-0.2, 0.0)) 
#take out coord_cartesian for full image. 
#this code techncially  gives 2 layers for data points - one for outliine and one for filled point

ggplot(ret_pca, aes(x=V3, y=V4))+ geom_point(size=2, shape=1)+  
  geom_text_repel(aes(label = ret_pca$V1), size = 3, max.overlaps = 15)+
  geom_point(aes(col=V1), size=2)+
  coord_cartesian(ylim=c(-0.1, 0.0), xlim=c(-0.15, 0.0)) 


#############------------

#this is to group samples
V0 = c("Late", "Early", "Late", "Late", "Late", "Late", "Early", "Late", "Early", "Early", "EU Late", "EU Late", "EU Late", "EU Late", "Early", "Early", "Early")
ret_pca$Time <- V0

Area = c("Unknown", "Wales", "SE", "SE", "SE", "SE", "SE", "S", "Wales", "SE", "Belgium", "Belgium", "France", "France", "S", "S", "SE")
ret_pca$Pop_Area <- Area


install.packages("sp")
library("sp")
install.packages("grid")
library("grid")
install.packages("gridExtra")
library("gridExtra")



time_pca <- ggplot(ret_pca, aes(x=V3, y=V4))+
  geom_text_repel(aes(label = ret_pca$V1), size = 3, max.overlaps = 15)+
  geom_point(aes(col=Time), size=2, shape=19)
#  coord_cartesian(ylim=c(-0.8, 0.8), xlim=c(-0.2, -0.1)) 
#take out coord_cartesian for full image
time_pca

zoom_time_pca <-ggplot(ret_pca, aes(x=V3, y=V4))+
  geom_text_repel(aes(label = ret_pca$V1), size = 3, max.overlaps = 15)+
  geom_point(aes(col=Time), size=2, shape=19)+
  coord_cartesian(ylim=c(-0.25, 0.25), xlim=c(-0.15, 0.01)) 
zoom_time_pca


area_pca <- ggplot(ret_pca, aes(x=V3, y=V4))+
  geom_text_repel(aes(label = ret_pca$V1), size = 3, max.overlaps = 15)+
  geom_point(aes(col=Pop_Area), size=2, shape=19)
#  coord_cartesian(ylim=c(-0.8, 0.8), xlim=c(-0.2, -0.1)) 
#take out coord_cartesian for full image
area_pca

zoom_area_pca <-ggplot(ret_pca, aes(x=V3, y=V4))+
  geom_text_repel(aes(label = ret_pca$V1), size = 3, max.overlaps = 15)+
  geom_point(aes(col=Pop_Area), size=2, shape=19)+
  coord_cartesian(ylim=c(-0.25, 0.25), xlim=c(-0.15, 0.01)) 
zoom_area_pca

ggplot


