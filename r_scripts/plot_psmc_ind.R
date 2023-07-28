#Plotting Ne results from msmc2
library(ggplot2)
library(dplyr)
library(stringr)
library(purrr)


#import results
#TODO:
#Provide path to result files as output and string to search for
dir=NULL
fileString=NULL
list_of_files <- list.files(path = "/storageToo/PROJECTS/Saad/scratch/", pattern = "test.*.txt", full.names=T)
#read in each file and store as an element of list
psmcdf <- list_of_files %>%
  setNames(nm = .) %>% 
  map_df(~read_delim(.x, delim="\t", col_types = cols(), col_names =F, col_select = c(1,2)), , .id = "file_name")   
#cleanup the sample name stored in the first column
psmcdf$IND <-str_extract(basename(psmcdf$file_name),  "[\\.](.*?)[\\.]")

#add column to differentiate between actual run vs bootstraps
psmcdf <- psmcdf %>% mutate(bootstrap=ifelse(IND==".0.", "run", "bootstrap"))

#add 1 to year column to avoid impossible values when log transforming
#psmcdf$X1 <- psmcdf$X1+1

#limit for y axis
y_lim=75

#Plot
psmcdf %>%  
  ggplot(aes(x=X1, y=X2/(1-.16), group=IND, alpha=bootstrap, line)) + 
  geom_step(col="red") + #plot the main line the 0.txt
  scale_alpha_manual(values=c(0.1,1)) + #aplha valye for main run vs. bootstraps
  scale_size_manual(values=c(3,0.5)) + #line width of run vs. bootstraps
  scale_x_log10(lim=c(5000,1e+06),breaks=c(1e+03, 5e+03,1e+04,5e+04,1e+05,1e+06)) + #control x-axis
  theme_bw() + xlab("Time Since Present (in years)") +
  guides(alpha=F) + #no legend for alpha values
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + #no gridlines
  scale_y_continuous(expression(N[e]~x~10^4~(effective~population~size)))+ 
  coord_cartesian(ylim=c(0, y_lim), expand =0 ) + # control y-axis limits
  annotate("rect", xmin = 16000, xmax = 31000, ymin=0, ymax=y_lim,alpha = .2) + # #add LGM
  geom_text(aes(x=22000, label="\nLGM", y= y_lim-3), colour="black", angle=90, vjust=2) +
  annotate("rect", xmin = 11700, xmax = 12900, ymin=0, ymax= y_lim,alpha= .2) + #add younger dryas
  geom_text(aes(x=11700, label="\nYD", y= y_lim-3), colour="black", angle=90)+
  annotate("rect", xmin = 116000, xmax = 129000, ymin=0, ymax=y_lim,alpha= .2) + #add eemian interglacial
  geom_text(aes(x=116000, label="\nEemian", y= y_lim-3), colour="black", angle=90)
  #geom_vline(xintercept = 8200, linetype="dotted", size = 0.3) + #disconnection from europe 6200 BCE
  #geom_text(aes(x=8200, label="\nDoggerland Submerged", y= max(X2)+10), colour="red", angle=90)