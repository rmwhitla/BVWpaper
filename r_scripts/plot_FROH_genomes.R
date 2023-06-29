#library for plotting and summarizing plink ROH output
library(detectRUNS)
library(dplyr)

#PATH to .hom run file from Plink 
hRunFile <- "/storage/PROJECTS/Rebecca/GenErodeResults/GenErode/results/historical/ROH/Aporia_crataegi-GCA_912999735.1-softmasked.historical.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb50.homwinsnp100.homwinhet2.homwinmis10.homhet3.hom"
#modern genomes
mRunFile <- "/storage/PROJECTS/Rebecca/GenErodeResults/GenErode/results/modern/ROH/Aporia_crataegi-GCA_912999735.1-softmasked.modern.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb50.homwinsnp100.homwinhet2.homwinmis10.homhet3.hom"

#Read in the data
hRuns <- readExternalRuns(inputFile = hRunFile, program="plink")
mRuns <- readExternalRuns(inputFile = mRunFile, program="plink")

#combine the two data frames
#allRuns <- rbind(hRuns, mRuns)

#provide group info
#GB samples
hRuns$group <- ifelse(hRuns$id %in% c("K05L", "NHM0247274489", "NHM0247274928", "NHM0247276019", "NHM0247276026",  "OX10", 
                                          "OX4",           "OX5",          "OX8"), "GB", hRuns$group)
#Suspect GB samples
hRuns$group <- ifelse(hRuns$id %in% c("NHM0247274898" , "NHM0247274918",  "NHM0247276027"), "GB?", hRuns$group)

#European
hRuns$group <- ifelse(hRuns$id %in% c("OX11", "OX13", "OX15","OX16" ), "EU", hRuns$group)

#modern
mRuns$group <- ifelse(mRuns$id %in% c("SRR7948941"), "JPM", mRuns$group)

#To use detectRUNS summary and plot functions, .ped and .map files from plink are required.
#These may not be available but can be generated from the .bim, .bed, .fam files as follows:
#plink --allow-extra-chr  --bfile PREFIXFORBFILES --recode --out NEWPREFIX

genotypeFilePath <- "/storageToo/PROJECTS/Saad/repos/BVWpaper/plink_ROH.ped"
mapFilePath <- "/storageToo/PROJECTS/Saad/repos/BVWpaper/plink_ROH.map"

#modern gt and map files
ModgenotypeFilePath <- "/storageToo/PROJECTS/Saad/repos/BVWpaper/plink_ROH_modern.ped"
ModmapFilePath <- "/storageToo/PROJECTS/Saad/repos/BVWpaper/plink_ROH_modern.map"

#removing Z chromosome
hRuns_noZ <- hRuns %>% filter(chrom!="Z")
mRuns_noZ <- mRuns %>% filter(chrom!="Z")

#Summarizing the plink -homozyg run
summaryList <- summaryRuns(runs=hRuns_noZ, mapFile = mapFilePath, genotypeFile = genotypeFilePath, Class=.1)
mSummaryList <- summaryRuns(runs=mRuns_noZ, mapFile = ModmapFilePath, genotypeFile = ModgenotypeFilePath, Class=.1)
#Summary stats could be useful for plotting
summaryList$result_Froh_class
summaryList$summary_ROH_mean_chr

#plotting runs along chromosomes
plot_Runs(runs=hRuns_noZ)
