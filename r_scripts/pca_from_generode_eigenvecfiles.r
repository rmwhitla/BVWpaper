#use the eigenvec file

install.packages("ggplot2")
library("ggplot2")
install.packages("ggrepel")
library("ggrepel")

setwd("/storage/PROJECTS/Rebecca/generode_test/GenErode/results/historical/pca")
ret_pca=read.table("Aporia_crataegi-GCA_912999735.1-softmasked.historical.merged.biallelic.fmissing0.2.eigenvec")
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
  coord_cartesian(ylim=c(-0.025, 0.15), xlim=c(-0.1, 0.025)) 


#############------------

#this is to group samples
V0 = c("Kent Late", "Unknown Late", "Unknown Late","Wales Early", "Kent Late", "Kent Late", "Kent Late", "Kent Late", "Kent Early", "Hampshire Late", "Wales Early", "Kent Early", "Europe 20C", "Europe 20C", "Europe 20C", "Europe 20C", "Hampshire Early", "Hampshire Early", "Kent Early")
ret_pca$Population <- V0

Groups = c("UK Late", "Unknown Late", "Unknown Late", "UK Early", "UK Late", "UK Late", "UK Late", "UK Late", "UK Early", "UK Late", "UK Early", "UK Early", "Europe Late", "Europe Late", "Europe Late", "Europe Late", "UK Early", "UK Early", "UK Early")
ret_pca$Grouped_Populations <- Groups


install.packages("sp")
library("sp")
install.packages("grid")
library("grid")
install.packages("gridExtra")
library("gridExtra")



full_pca <- ggplot(ret_pca, aes(x=V3, y=V4))+
  geom_text_repel(aes(label = ret_pca$V1), size = 3, max.overlaps = 15)+
  geom_point(aes(col=Grouped_Populations), size=2, shape=19)
#  coord_cartesian(ylim=c(-0.8, 0.8), xlim=c(-0.2, -0.1)) 
#take out coord_cartesian for full image
full_pca

zoom_pca <-ggplot(ret_pca, aes(x=V3, y=V4))+
  geom_text_repel(aes(label = ret_pca$V1), size = 3, max.overlaps = 15)+
  geom_point(aes(col=Grouped_Populations), size=2, shape=19)+
  coord_cartesian(ylim=c(-0.025, 0.15), xlim=c(-0.075, -0.04)) 
zoom_pca

ggplot


