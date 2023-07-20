#plot boxplots of heterozygosity from angsd

#required packages
library(ggplot2)
library(readr)
library(purrr)
library(stringr)
library(dplyr)
library("ggrepel")

#PATH to folder constaining .est.ml files from realSFS
sfsPath="/storageToo/PROJECTS/Saad/repos/BVWpaper/angsd_het"

#get all *est.ml filenames in sfsPATH
estim <- list.files(path = sfsPath, pattern = "*est.ml", full.names=T)

#read in each file and store as an element of list
angsdThetaDf <- estim %>%
  setNames(nm = .) %>%
  map_df(~read_delim(.x, col_names=F, delim=" ", n_max=1),  .id = "file_name")   


#extract sample name and make a new column with it
angsdThetaDf$sample_name <-str_extract(basename(angsdThetaDf$file_name),  "[^\\.]+")
#Calculate theta estimate
angsdThetaDf$theta_est<-angsdThetaDf$X2/rowSums(angsdThetaDf[,c("X1","X2","X3")])

#read in info file
info <- read_delim("/storageToo/PROJECTS/Saad/repos/BVWpaper/infofile.tsv", delim="\t", col_types = cols())

#merge the two data frames
angsdThetaDf <- inner_join(angsdThetaDf, info, by="sample_name")
#boxplot by location
angsdThetaDf %>% 
  ggplot(aes(x=Region, y=as.numeric(theta_est)*1000)) +
  geom_boxplot(outlier.shape = NA) + geom_jitter(aes(shape=origin), size=2) + theme_bw()  + xlab("Region of Origin") + ylab("Heterozygotes/1000 basepairs")

#scatterplot of british samples over years
angsdThetaDf  %>% 
  filter(Region=="GB") %>%
  ggplot(aes(x=year, y=as.numeric(theta_est)*1000)) +
  geom_point(size=3,pch=21,aes(fill=location)) +  scale_fill_manual(values=c("#ffb14e", "#fa8775","#ea5f94", "#cd34b5", "#aca7a7"))+
  theme_bw()  + xlab("Year") + ylab("Heterozygotes/1000 basepairs") + geom_smooth(method='lm') +
  geom_text_repel(aes(label = sample_name), size = 3, max.overlaps = 30)+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

#t.test
#remove japanese sample if present
theatdf <- angsdThetaDf  %>% 
  filter(origin!="Japan")

t.test((theta_est)*1000~Region, data=theatdf)
