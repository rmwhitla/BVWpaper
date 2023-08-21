#Plots barplot of admixture ancestry from NGS admix output

#requires
library(dplyr)
library(ggplot2)

#---------------------------------------------------------
#PATHS to files

#pop label file
popPATH="/storageToo/PROJECTS/Saad/repos/BVWpaper/poplabel"

#path to inferred admixture proportions file
admixPATH="/storageToo/PROJECTS/Saad/repos/BVWpaper/angsd_out/NGSAdmix_0.1.missing.K3_3.qopt"
#--------------------------------------------------------

#read in pop label file
pop <- read.table(popPATH, header=T)
# Read inferred admixture proportions file
q<-read.table(admixPATH)

#Plot in base R
# order according to population
ord<-order(pop[,2])
barplot(t(q)[,ord],col=2:10,space=0,border=NA,xlab="",ylab="Admixture proportions for K=2", names.arg=pop[ord,1], cex.names=0.75, las=2)
text(tapply(1:nrow(pop),pop[ord,2],mean),-.3,unique(pop[ord,2]),xpd=T)
abline(v=cumsum(sapply(unique(pop[ord,2]),function(x){sum(pop[ord,2]==x)})),col=1,lwd=1.2)

#plotting with ggplot2
admixData <- cbind(pop,q)
#arrange by labels
admixData <- admixData %>% arrange(PCA)
#convert ancestry proportions to long format for ggplot2
admixData <- admixData %>% pivot_longer(starts_with("V"), names_to = "Ancestry")
#plot stacked barplot
admixData %>% 
  ggplot(aes(x=fct_inorder(Short_ID), y=value, fill=Ancestry)) +
  geom_bar(position="stack", stat="identity", width=1) +
  theme_bw() + xlab("") + ylab("Ancestry Proportion with K=2") +
  scale_fill_manual (values=c("salmon", "khaki"), labels=c("Europe", "GB")) + #Legend control
  theme(plot.title = element_text( hjust=0.02, size = 20, face = "bold"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size=10),
        legend.position = c(0.92,.2)) + #no gridlines
  coord_cartesian( expand =0 ) + #no additional space at bottom of margins
  geom_vline(xintercept =cumsum(sapply(unique(pop[ord,2]),function(x){sum(pop[ord,2]==x)}))[1]+0.5,col=1,lwd=1.5) + #demarcate end of samples group
  geom_vline(xintercept =cumsum(sapply(unique(pop[ord,2]),function(x){sum(pop[ord,2]==x)}))[2]+0.5,col=1,lwd=1.5) + #demarcate enf of samples group
  ggtitle("C")
