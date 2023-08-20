#library for plotting and summarizing plink ROH output
library(detectRUNS)
library(dplyr)
library(ggplot2)
library(readr)

#PATH to .hom run file Generode Run 
RunFile <- "/storage/PROJECTS/Rebecca/GenErodeResults/GenErode/paramtestresults//historical/ROH/Aporia_crataegi-GCA_912999735.1-softmasked.historical.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb50.homwinsnp100.homwinhet2.homwinmis10.homhet3.hom"
#RunFile <- "/storage/PROJECTS/Rebecca/GenErodeResults/CBGenerode/GenErode/10Xresults/modern/ROH/Polyommatus_icarus-GCA_937595015.1-softmasked.modern.merged.biallelic.fmissing0.hwe0.05.homsnp25.homkb50.homwinsnp100.homwinhet2.homwinmis10.homhet3.hom"

#Read in the data
Runs <- readExternalRuns(inputFile = RunFile, program="plink")

#combine the two data frames
#allRuns <- rbind(hRuns, mRuns)

#provide group info BVW
#GB samples
Runs$group <- ifelse(hRuns$id %in% c("K05L", "NHM0247274489", "NHM0247274928", "NHM0247276019", "NHM0247276026",  "OX10", 
                                         "OX4",           "OX5",          "OX8"), "GB", Runs$group)
#PCA GB samples
Runs$group <- ifelse(hRuns$id %in% c("NHM0247274898" , "NHM0247274918",  "NHM0247276027"), "Europe", Runs$group)

#European
Runs$group <- ifelse(hRuns$id %in% c("OX11", "OX13", "OX15","OX16" ), "Europe", Runs$group)

#Group info for Picarus
#Runs$group <- ifelse(Runs$id %in% c("TULF73", "DGCF87", "DGCM100", "BMDF276"), "GB", Runs$group)
#Runs$group <- ifelse(Runs$id %in% c("FRNM006",  "FRNM003", "FRNM007"), "Europe", hRuns$group)
#To use the following detectRUNS summary and plot functions, .ped and .map files from plink are required.
#These may not be available but can be generated from the .bim, .bed, .fam files as follows:
#plink --allow-extra-chr  --bfile PREFIXFORBFILES --recode --out NEWPREFIX

genotypeFilePath <- "/storageToo/PROJECTS/Saad/repos/BVWpaper/plink_files/plink_ROH.ped"
mapFilePath <- "/storageToo/PROJECTS/Saad/repos/BVWpaper/plink_files/plink_ROH.map"


#removing Z chromosome
Runs_noZ <- Runs %>% filter(chrom!="Z")

#Summarizing the plink -homozyg run
summaryList <- summaryRuns(runs=Runs_noZ, mapFile = mapFilePath, genotypeFile = genotypeFilePath, Class=.1)

#Summary stats could be useful for plotting
summaryList$result_Froh_class
summaryList$summary_ROH_mean_chr
summaryList$summary_ROH_count

#plotting runs along chromosomes
plot_Runs(runs=hRuns_noZ)
#TODO:
#find better way of plotting e.g. all chromosomes in a single figure

#plot fROH across samples
#read in info file
info <- read_delim("/storageToo/PROJECTS/Saad/repos/BVWpaper/infofile.tsv", delim="\t", col_types = cols())
FROH_class <- summaryList$result_Froh_class
FROH_class <- FROH_class %>% rename("sample_name" = "id")
FROH_df <- inner_join(FROH_class, info, by="sample_name")

#Summarize data for FROH class 0.1 for plotting as barplot with st dev bars
FROH_summary <- FROH_df %>%
  group_by(group) %>%
  summarise(mean_FROH_class0.1 = mean(Froh_Class_0.1),
            sd_FROH_class0.1 = sd(Froh_Class_0.1),
            mean_FROH_class0.8 = mean(Froh_Class_0.8, na.rm=T),
            sd_FROH_class0.8 = sd(Froh_Class_0.8, na.rm=T))
#Plot
FROH_summary %>%
  ggplot() +
  geom_bar(aes(x=group, y=mean_FROH_class0.1),fill="white",stat="identity", col="black") + #FROH 0.1-0.2 Mb bars
  geom_errorbar( aes(x=group, ymin=mean_FROH_class0.1-sd_FROH_class0.1, ymax=mean_FROH_class0.1+sd_FROH_class0.1), width=0.2, colour="black", alpha=0.9, size=1) +  #FROH 0.1-0.2 Mb sd
  geom_bar(aes(x=group, y=mean_FROH_class0.8, fill=group),stat="identity", alpha=0.7) + #FROH > 0.8 Mb bars
  scale_fill_manual(values=c("#ffa600", "#003f5c")) +
  geom_errorbar( aes(x=group, ymin=mean_FROH_class0.8-sd_FROH_class0.8, ymax=mean_FROH_class0.8+sd_FROH_class0.8), width=0.2, colour="red", alpha=0.9, size=1) +  #FROH >0.8 Mb sd
  ylab("FROH") + xlab("") + 
  theme_bw() + 
  guides(fill=F) +
  theme( panel.grid.major = element_blank(), 
         panel.grid.minor = element_blank()) 

#compare admixed vs Gb individuals for Historical samples
FROH_df %>%
  filter(Admix != "Europe") %>%
  ggplot(aes(x=Admix, y=Froh_Class_0.1)) +
  geom_point()
#test
FROH_df %>%
  filter(Admix != "Europe") %>%
  t_test(Froh_Class_0.1~Admix)

#test accounting for coverage
#fit the model
mod <- lm(Froh_Class_0.1 ~ mean_coverage_recaled_bams + actual_region, data = FROH_df)
#Make the anova table
anova(mod)
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
pwc <- FROH_df %>% 
  emmeans_test(
    Froh_Class_0.1~ actual_region, covariate = mean_coverage_recaled_bams,
    p.adjust.method = "bonferroni"
  )
pwc
get_emmeans(pwc)


#-------------------------------------------------------------------------------
#Plotting Karytopes of ROH
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("karyoploteR")

#read in the genome file
library(karyoploteR)

acrataegi.genome <- toGRanges("/storageToo/PROJECTS/Saad/repos/BVWpaper/ROH_plotting_files/Aporia_crataegi-GCA_912999735.1-softmasked.genome.noZ.txt")

library(detectRUNS)
#read in ROH data from Generode output 
RunFile <- "/storage/PROJECTS/Rebecca/GenErodeResults/GenErode/paramtestresults//historical/ROH/Aporia_crataegi-GCA_912999735.1-softmasked.historical.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb50.homwinsnp100.homwinhet2.homwinmis10.homhet3.hom"
roh <- readExternalRuns(inputFile = RunFile, program="plink")
#filter a single indivdual and Z colum
roh_NHM0247276026 <- roh %>%
  filter(id == "NHM0247276026") %>%
  filter(chrom !=  "Z") # %>%
  #mutate(name="ROH") %>%
  #mutate(gieStain="acen") %>%
  #select(-c(group,id,nSNP))
#rename to and from columns
#add columns to work with plotKaryotype functions


#convert data frame to gRanges
roh_NHM0247276026_gr <- makeGRangesFromDataFrame(roh_NHM0247276026,
                                        keep.extra.columns=FALSE,
                                        ignore.strand=T,
                                        seqinfo=NULL,
                                        seqnames.field=c("seqnames", "seqname",
                                                         "chromosome", "chrom",
                                                         "chr", "chromosome_name",
                                                         "seqid"),
                                        start.field="from",
                                        end.field=c("to"),
                                        strand.field="strand",
                                        starts.in.df.are.0based=FALSE)


kp <- plotKaryotype(genome = acrataegi.genome, plot.type = 1 ) #plot the chrosomes
kpPlotRegions(kp, data=roh_NHM0247276026_gr, data.panel="ideogram") # add the roh
kpAddMainTitle(kp , main ="NHM0247276026") # add sample title
kpAddBaseNumbers(kp, tick.dist = 1000000, tick.len = 10, tick.col="red", cex=.5,
                 minor.tick.dist = 100000, minor.tick.len = 5, minor.tick.col = "gray") #add base numbers in MB
#kpPlotBAMDensity(kp, 
#                data="/storage/PROJECTS/Rebecca/GenErodeResults/GenErode/paramtestresults//historical/mapping/Aporia_crataegi-GCA_912999735.1-softmasked/NHM0247276026.merged.rmdup.merged.realn.rescaled.bam",
#                window.size=1e6, col="black",
#                data.panel = 1)
#kpAddLabels(kp, labels="Coverage", data.panel = 1, cex=0.5)
kpPlotBAMCoverage(kp, 
                  data="/storage/PROJECTS/Rebecca/GenErodeResults/GenErode/paramtestresults//historical/mapping/Aporia_crataegi-GCA_912999735.1-softmasked/NHM0247276026.merged.rmdup.merged.realn.rescaled.bam",
                  max.valid.region.size=250e6, data.panel=1) #add coverage info
#FROH_df %>% 
#  filter(actual_region=="GB") %>%
#  ggplot(aes(x=year, y=Froh_Class_0.2)) +
#  geom_point(size=3) +  #scale_fill_manual(values=c("#ffb14e", "#fa8775","#ea5f94", "#cd34b5", "#aca7a7"))+
#  theme_bw()  + xlab("Year") + ylab("FROH 200 kb") + geom_smooth(method='lm') +
#  geom_text_repel(aes(label = sample_name), size = 3, max.overlaps = 30)+
#  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) 
  
  #geom_point(aes(x=1908, y=0.08265762, color="blue")) #adding japanese point manually

#plot FROH between groups
#FROH_df %>% 
#  ggplot(aes(x=actual_region, y=Froh_Class_0.2)) +
#  geom_boxplot() +geom_jitter()+ #scale_fill_manual(values=c("#ffb14e", "#fa8775","#ea5f94", "#cd34b5", "#aca7a7"))+
#  theme_bw()  + xlab("Region") + ylab("FROH 100 kb") + 
#  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

#wilcox.test(Froh_Class_0.1~Region, data=FROH_df)
#summary(aov(Froh_Class_0.1~mean_coverage_recaled_bams+ actual_region, data=FROH_df))
#FROH_df_GB <- FROH_df  %>% filter(actual_region=="GB")
#anova(lm(Froh_Class_0.4~mean_coverage_recaled_bams+ year, data=FROH_df_GB))
