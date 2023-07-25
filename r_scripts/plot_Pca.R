#PCA plots for outputs from generode
library("ggplot2")
library("ggrepel")
library(dplyr)

#read in info file
info <- read_delim("/storageToo/PROJECTS/Saad/repos/BVWpaper/infofile.tsv", delim="\t", col_types = cols())


################################################################
#Modern + Historical samples
#CHANGE PATHS AS REQUIRED
#Path to eigenvector file
allevecPATH<- "/storageToo/PROJECTS/Saad/scratch/Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.maf.01.eigenvec"
#Path to eigenvalue gile
allevalPATH <- "/storageToo/PROJECTS/Saad/scratch/Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.maf.01.eigenval"

#read in the data
alleigvec <- read.table(allevecPATH)
alleigval <- read.table(allevalPATH)

#Make character vector for label for PCs
PCnames = vector()
for (i in 3:dim(alleigvec)[2]-2) { PCnames <- c(PCnames, c(paste0("PC", i)))}

#add names to columns, note first two columns in alleigvec are duplicates
alleigvec <- alleigvec[2:dim(alleigvec)[2]]
names(alleigvec) <- c("sample_name", PCnames)

#Combine info and eigenvector table
allPCAdf <- inner_join(alleigvec, info, by="sample_name")

#caluclate variance explained by PC1,2,3
pc1=round(alleigval[1,1]/sum(alleigval[1]) *100,1)
pc2=round(alleigval[2,1]/sum(alleigval[1]) *100,1)
pc3=round(alleigval[3,1]/sum(alleigval[1]) *100,1)

#Plotting time
allPCAdf %>%
  ggplot(aes(x=PC1, y=PC2,shape=Region, fill=location)) +
  geom_point(size=3, aes())+ scale_shape_manual(values=c(21,24,22)) +
  scale_fill_manual(values=c("#ffb14e", "#0000ff", "#fa8775", "#000000","#0000ff", "#ea5f94", "#cd34b5", "#aca7a7"))+
  geom_text_repel(aes(label = sample_name), size = 3, max.overlaps = 45)+
  guides(fill=guide_legend(override.aes = list(shape=21))) +
  xlab(paste0("PC1 ", pc1, "%")) + ylab(paste0("PC1 ", pc2, "%"))+ coord_fixed(ratio=1) + stat_ellipse(aes(group=Region)) +
  theme_bw() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())


################################################################################
#Historical samples only

#CHANGE PATHS AS REQUIRED
#Path to eigenvector file
hisevecPATH<- "/storage/PROJECTS/Rebecca/GenErodeResults/GenErode/results/historical/pca/Aporia_crataegi-GCA_912999735.1-softmasked.historical.merged.biallelic.fmissing0.1.eigenvec"
#Path to eigenvalue gile
hisevalPATH <- "/storage/PROJECTS/Rebecca/GenErodeResults/GenErode/results/historical/pca/Aporia_crataegi-GCA_912999735.1-softmasked.historical.merged.biallelic.fmissing0.1.eigenval"

#read in the data
hiseigvec <- read.table(hisevecPATH)
hiseigval <- read.table(hisevalPATH)

#Make character vector for label for PCs
PCnames = vector()
for (i in 2:dim(hiseigvec)[2]-1) { PCnames <- c(PCnames, c(paste0("PC", i)))}

#add names to columns, note first two columns in alleigvec are duplicates
#hiseigvec <- hiseigvec[2:dim(hiseigvec)[2]]
names(hiseigvec) <- c("sample_name", PCnames)

#Combine info and eigenvector table
hisPCAdf <- inner_join(hiseigvec, info, by="sample_name")

#caluclate variance explained by PC1,2,3
hiseigval[1,1]/sum(hiseigval[1])
hiseigval[2,1]/sum(hiseigval[1])
hiseigval[3,1]/sum(hiseigval[1])

#Plotting time
hisPCAdf %>%
  ggplot(aes(x=PC1, y=PC2, group=Region)) +
  geom_point(size=3, alpha=0.5,aes(shape=Region))+
  geom_text_repel(aes(label = sample_name), size = 3, max.overlaps = 30)+
  xlab("PC1 10.5%") + ylab("PC2 9.2%")+
  theme_bw() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
