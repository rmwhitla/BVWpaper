#Plotting Ne results from msmc2
library(ggplot2)
library(dplyr)
library(stringr)
library(purrr)

#SCRIPT NEEDS TO BE UPDATED FOR BOOTSTRAP PLOTTING

#per-site-per-generation mutation rate for heliconius fro, Keightley et al. 2015, Mol, Biol. Evol
mu=2.9e-9
#generation time in yeasr
gen=0.5

#import results
#TODO:
#Provide path to result files as output and string to search for
dir=NULL
fileString=NULL
list_of_files <- list.files(path = "/storageToo/PROJECTS/Saad/PicarusPopSize/ProcessedData/psmc_out/BMDF276/", pattern = "*0.txt", full.names=T)
#read in each file and store as an element of list
psmcdf <- list_of_files %>%
  setNames(nm = .) %>% 
  map_df(~read_delim(.x, delim="\t", col_types = cols(), col_names =F, col_select = c(1,2)), , .id = "file_name")   
#cleanup the sample name stored in the first column
psmcdf$IND <-str_extract(basename(psmcdf$file_name),  "[^\\.]+")
#psmcdf$IND <-str_extract(basename(msmc2df$file_name),  "[^_]+")
#Convert time to year

#add 1 to year column to avoid impossible values when log transforming
psmcdf$X1 <- psmcdf$X1+1

#Plot
psmcdf %>%  
  ggplot(aes(x=X1, y=X2, colour =IND, group=IND)) + geom_step(size=1.5)   +scale_x_log10(lim=c(1000,1e+06),breaks=c(1e+03, 5e+03,1e+04,5e+04,1e+05,1e+06)) +
  theme_bw() + xlab("Time Since Present (in years)") +
  scale_y_continuous(expression(N[e]~x~10^4~(effective~population~size)),expand = c(0,0))+ 
  coord_cartesian(ylim=c(0, max(psmcdf$X2)+20)) +
  annotate("rect", xmin = 16000, xmax = 31000, ymin=0, ymax=  max(psmcdf$X2)+10,alpha = .3) + # #add LGM
  geom_text(aes(x=22000, label="\nLGM", y= max(X2)+20), colour="black") +
  annotate("rect", xmin = 11700, xmax = 12900, ymin=0, ymax= max(psmcdf$X2)+10,alpha= .5) + #add younger dryas
  geom_text(aes(x=11700, label="\nYD", y= max(psmcdf$X2)+20), colour="black")+
  annotate("rect", xmin = 116000, xmax = 129000, ymin=0, ymax= max(psmcdf$X2)+10,alpha= .5) + #add younger dryas
  geom_text(aes(x=116000, label="\nEemian", y= max(psmcdf$X2)+20), colour="black")
  #geom_vline(xintercept = 8200, linetype="dotted", size = 0.3) + #disconnection from europe 6200 BCE
  #geom_text(aes(x=8200, label="\nDoggerland Submerged", y= max(X2)+10), colour="red", angle=90)