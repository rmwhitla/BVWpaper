#plot boxblots of heterozygosity from mlRho

#required packages
library(ggplot2)
#install.packages("readr")
library(readr)
#install.packages("purrr")
library(purrr)
#install.packages("stringr")
library(stringr)
#install.packages("dplyr")
library(dplyr)
library("ggrepel")

#paths to folders containing mlRho output files
#historical data
hist_dir="/storage/PROJECTS/Rebecca/GenErodeResults/GenErode/results/historical/mlRho/Aporia_crataegi-GCA_912999735.1-softmasked/"
#modern data
mod_dir="/storage/PROJECTS/Rebecca/GenErodeResults/GenErode/results/modern/mlRho/Aporia_crataegi-GCA_912999735.1-softmasked/"

#Get filenames for autosomes only
hist_files <- list.files(path = hist_dir, pattern = "*autos.mlRho.txt", full.names=T)
mod_files <- list.files(path = mod_dir, pattern = "*autos.mlRho.txt", full.names=T)

all_files <- c(hist_files, mod_files)

#read in each file and store as an element of list
mlRhoDf <- all_files %>%
  setNames(nm = .) %>%
  map_df(~read_delim(.x, delim="\t", col_types = cols(), col_names =c("d", "n", "theta", "epsilon", "-log(L)"), skip=1, comment="#"), , .id = "file_name")   


#extract sample name and make a new column with it
mlRhoDf$sample_name <-str_extract(basename(mlRhoDf$file_name),  "[^\\.]+")
#Extract theta estimate from lower/upper bounds
mlRhoDf$theta_est<-str_match(mlRhoDf$theta, "<\\s*(.*?)\\s*<")[,2]

#read in info file
info <- read_delim("/storage/PROJECTS/Rebecca/analysis/infofile.tsv", delim="\t", col_types = cols())

#merge the two data frames
mlRhoDf <- inner_join(mlRhoDf, info, by="sample_name")


#boxplot by location
mlRhoDf %>% 
  ggplot(aes(x=Region, y=as.numeric(theta_est)*1000)) +
  geom_boxplot(outlier.shape = NA) + geom_jitter(aes(shape=origin), size=2) + theme_bw()  + xlab("Region of Origin") + ylab("Heterozygotes/1000 basepairs")

#scatterplot of british samples over years
mlRhoDf %>% 
  filter(Region=="GB") %>%
  ggplot(aes(x=year, y=as.numeric(theta_est)*1000, group=location)) +
  geom_point(size=3,pch=21,aes(fill=location)) +  scale_fill_manual(values=c("#ffb14e", "#fa8775","#ea5f94", "#cd34b5", "#aca7a7"))+
  theme_bw()  + xlab("Year") + ylab("Heterozygotes/1000 basepairs") + 
  geom_text_repel(aes(label = sample_name), size = 3, max.overlaps = 30)+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

#Boxplot comparing kent vs other GB samples
mlRhoDf %>% 
  filter(Region=="GB" & location != "Unknown") %>%
  ggplot(aes(x=kent, y=as.numeric(theta_est)*1000)) +
  geom_boxplot(outlier.shape = NA) + geom_jitter() + theme_bw()  + xlab("Kent vs. Rest of GB") + ylab("Heterozygotes/1000 basepairs")
