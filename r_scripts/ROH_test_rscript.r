#ROH

library(ggplot2)
install.packages("readr")
library(readr)
install.packages("purrr")
library(purrr)
install.packages("stringr")
library(stringr)
install.packages("dplyr")
library(dplyr)

ROH_bvw=read.table("Aporia_crataegi-GCA_912999735.1-softmasked.historical.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb100.homwinsnp50.homwinhet2.homwinmis10.homhet3.hom.indiv")

#read in info file
info <- read_delim("/storage/PROJECTS/Rebecca/analysis/infofile.tsv", delim="\t", col_types = cols())

colnames(ROH_bvw) <- c("sample_name", "IID", "PHE", "NSEG", "KB", "KBAVG")

#merge the two data frames
ROH_info <- inner_join(ROH_bvw, info, by="sample_name")

ROH_info %>%
  ggplot(aes(x = Region, y = as.numeric(NSEG))) +
  geom_boxplot() +
  geom_jitter(aes(shape = Region), size = 2) +
  theme_bw() +
  xlab("Region") +
  ylab("Number of ROH")
#control for different number of samples?

ROH_info %>%
  ggplot(aes(x = kent, y = as.numeric(NSEG))) +
  geom_boxplot() +
  geom_jitter(aes(shape = kent), size = 2) +
  theme_bw() +
  xlab("From Kent?") +
  ylab("Number of ROH")


V0 = c("Late", "Early", "Late", "Late", "Late", "Late", "Early", "Late", "Early", "Early", "EU Late", "EU Late", "EU Late", "EU Late", "Early", "Early", "Early")
ROH_info$Time <- V0

ROH_info %>%
  ggplot(aes(x = Time, y = as.numeric(NSEG))) +
  geom_boxplot() +
  geom_jitter(aes(shape = Time), size = 2) +
  theme_bw() +
  xlab("Early (pre1880) or late (post1880)?") +
  ylab("Number of ROH")


#scattterplot - year / roh size

ROH_info %>% 
  ggplot(aes(x=as.numeric(KBAVG), y=as.numeric(year))) +
  geom_point() + theme_bw()  + xlab("Average ROH size") + ylab("Year of Specimen Collection") + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

#scatterplot - year / # roh

ROH_info %>% 
  
  ggplot(aes(x=as.numeric(NSEG), y=as.numeric(year))) +
  geom_point() + theme_bw()  + xlab("Number of ROH segments") + ylab("Year of Specimen Collection") + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())



  