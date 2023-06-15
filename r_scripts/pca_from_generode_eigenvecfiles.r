#use the eigenvec file

install.packages("ggplot2")
library("ggplot2")
install.packages("ggrepel")
library("ggrepel")
install.packages("wesanderson")
library("wesanderson")

ret_pca=read.table("Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.minallelefreq0.1.eigenvec")
attach(ret_pca)

colnames(ret_pca) <- c("sample_name", "sample", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10", "PC11", "PC12", "PC13", "PC14", "PC15", "PC16", "PC17")

#read in info file
info <- read_delim("/storage/PROJECTS/Rebecca/analysis/infofile.tsv", delim="\t", col_types = cols())

#merge the two data frames
PCA_info <- inner_join(ret_pca, info, by="sample_name")



ggplot(PCA_info, aes(x=PC1, y=PC2))+ geom_point(size=2, shape=1)+  
  geom_text_repel(aes(label = PCA_info$sample_name), size = 3, max.overlaps = 15)+
  geom_point(aes(col=Region), size=2)+
  coord_fixed()+
  ylab("PC2 8.93%")+
  xlab("PC1 12.51%")+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
               panel.background = element_blank(), axis.line = element_line(colour = "black"))
#this code techncially  gives 2 layers for data points - one for outliine and one for filled point
#get pca values frmo eigenval files - each number is effect of pc1 as proportion of total of all numbers

##group by pre/post 11880?