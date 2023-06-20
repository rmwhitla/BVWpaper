#PCA plots for outputs from generode
library("ggplot2")
library("ggrepel")
library(ddplyr)
library(stringr)

#read in info file
info <- read_delim("/storageToo/PROJECTS/Saad/repos/BVWpaper/infofile.tsv", delim="\t", col_types = cols())

#read in covariance matix output from angsd
C <- as.matrix(read.table("/storageToo/PROJECTS/Saad/repos/BVWpaper/bash_scripts/angsdPCA.cov"))
#perform eigendecomposition of matrix
e <- eigen(C)

#read in order of samples from PCAangsd
sampleOrder <- read.table("/storageToo/PROJECTS/Saad/repos/BVWpaper/bash_scripts/BAMS.txt")
#combine eigenvectors with info
pca <- data.frame(sample_name=str_extract(basename(sampleOrder$V1),  "[^\\.]+"), PC1=e$vectors[,1], PC2=e$vectors[,2], PC3=e$vectors[,3])
#Combine info and eigenvector table
angsdPCAdf <- inner_join(pca, info, by="sample_name")
################################################################
#Plotting the PCA
#calculate variance explained by PC1,2,3
pc1=round(e$values[1]/sum(e$values) *100,2)
pc2=round(e$values[2]/sum(e$values) *100,2)
pc3=round(e$values[3]/sum(e$values) *100,2)

#Plotting time
angsdPCAdf %>%
  ggplot(aes(x=PC1, y=PC2, group=location)) +
  geom_point(size=3, pch=21,aes(fill=location))+ 
  scale_fill_manual(values=c("#ffb14e", "#0000ff", "#fa8775", "#000000","#0000ff", "#ea5f94", "#cd34b5", "#aca7a7"))+
  geom_text_repel(aes(label = sample_name), size = 3, max.overlaps = 45)+
  xlab(paste0("PC1 ", pc1, "%")) + ylab(paste0("PC1 ", pc2, "%"))+ coord_fixed(ratio=1) +
  theme_bw() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())


################################################################################

