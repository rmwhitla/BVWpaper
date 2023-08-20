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
  ggplot(aes(x=actual_region, y=as.numeric(theta_est)*1000, fill=actual_region, col=actual_region),aplha=0.75) +
  geom_violin() + geom_jitter(aes(shape=Region_postPCA), size=2) + 
  scale_fill_manual(values=c("#ffa600", "#003f5c")) +
  guides(fill=F, col=F, shape=F) +
  theme_bw()  + xlab("Region of Origin") + ylab("Heterozygotes/1000 basepairs")

#ANCOVA
mod <- lm(as.numeric(theta_est)*1000~mean_coverage_recaled_bams+actual_region, data=angsdThetaDf)
anova(mod)

mlRhoDf %>%
  ggplot(aes(x=mean_coverage_recaled_bams, y=as.numeric(theta_est)*1000, group=actual_region) ) +
  geom_point()+
  stat_smooth(method = "lm",
                formula = y ~ x,
                geom = "smooth") +
  theme_bw()
#model diagnostics
# Inspect the model diagnostic metrics
library(broom)
library(rstatix)
library(emmeans)
model.metrics <- augment(mod) %>%
  select(-.hat, -.sigma, -.fitted) # Remove details
head(model.metrics, 3)
# Assess normality of residuals using shapiro wilk test
shapiro_test(model.metrics$.resid)
#homogeneity of variances
model.metrics %>% levene_test(.resid ~ actual_region)
#Outliers
model.metrics %>% 
  filter(abs(.std.resid) > 3) %>%
  as.data.frame()

#Adjusted means comparison for accounting for coverage

pwc <- angsdThetaDf %>% 
  emmeans_test(
    as.numeric(theta_est)*1000 ~ actual_region, covariate = mean_coverage_recaled_bams,
    p.adjust.method = "bonferroni"
  )
pwc
get_emmeans(pwc)

#compare admixed vs GB
#compare admixed vs Gb individuals for Historical samples
angsdThetaDf%>%
  filter(Admix != "Europe") %>%
  ggplot(aes(x=Admix, y=as.numeric(theta_est)*1000 )) +
  geom_point()
#test
FROH_df %>%
  filter(Admix != "Europe") %>%
  t_test(Froh_Class_0.1~Admix)


#scatterplot of british samples over years
#angsdThetaDf  %>% 
#  ggplot(aes(x=year, y=as.numeric(theta_est)*1000)) +
 # filter(actual_region=="GB") %>%
#  geom_point(size=3,pch=21,aes(fill=location)) +  scale_fill_manual(values=c("#ffb14e", "#fa8775","#ea5f94", "#cd34b5", "#aca7a7"))+
#  geom_text_repel(aes(label = sample_name), size = 3, max.overlaps = 30)+
#  theme_bw()  + xlab("Year") + ylab("Heterozygotes/1000 basepairs") + geom_smooth(method='lm') +
#  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

#scatterplot of coverage against heterozyosity
angsdThetaDf %>% 
  ggplot(aes(x=mean_coverage_recaled_bams, y=as.numeric(theta_est)*1000)) +
  geom_point() +
  geom_text_repel(aes(label = sample_name), size = 3, max.overlaps = 30)+
  theme_bw()  + xlab("Mean coverage") + ylab("Heterozygotes/1000 basepairs")

#t.test
#remove japanese sample if present
#theatdf <- angsdThetaDf  %>% 
#  filter(origin!="Japan")

summary(aov((theta_est)*1000~mean_coverage_recaled_bams+ actual_region, data=angsdThetaDf ))
anova(lm(theta_est~mean_coverage_recaled_bams+year, data=angsdThetaDf,
         subset= angsdThetaDf$actual_region == "GB"))

angsdThetaDf_GB <- angsdThetaDf  %>% filter(actual_region=="GB")
anova(lm(theta_est~mean_coverage_recaled_bams + year, data=angsdThetaDf_GB,
         subset= angsdThetaDf$short_specimen_name != "NHM050"))
anova(lm(theta_est~mean_coverage_recaled_bams + year, data=angsdThetaDf_GB))

