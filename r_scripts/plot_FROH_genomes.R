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
hRuns$group <- ifelse(hRuns$id %in% c("NHM0247274898" , "NHM0247274918",  "NHM0247276027"), "EU", hRuns$group)

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

#modified version of fucntion plot_Runs for plotting
plot_Runs_mod <- function (runs, suppressInds = FALSE, savePlots = FALSE, separatePlots = FALSE, 
                           outputName = NULL) 
{
  chrom <- NULL
  from <- NULL
  to <- NULL
  group <- NULL
  chr_order <- c((0:99), "X", "Y", "XY", "MT", "Z", "W")
  list_chr = unique(runs$chrom)
  new_list_chr = as.vector(sort(factor(list_chr, levels = chr_order, 
                                       ordered = TRUE)))
  plot_list <- list()
  for (chromosome in new_list_chr) {
    krom <- subset(runs, chrom == chromosome)
    teilsatz <- krom[, c(5, 6, 2, 1)]
    teilsatz <- teilsatz[order(teilsatz$group), ]
    newID <- seq(1, length(unique(teilsatz$id)))
    id <- unique(teilsatz$id)
    teilsatz$NEWID = newID[match(teilsatz$id, id)]
    optionen <- ggplot2::scale_y_discrete("IDs", limits = unique(teilsatz$id))
    alfa <- 1
    grosse <- 1
    if (length(id) > 50) {
      optionen <- ggplot2::theme(axis.text.y = element_blank(), 
                                 axis.title.y = element_blank(), axis.ticks.y = element_blank())
      alfa <- 0.75
      grosse <- 0.25
    }
    if (suppressInds) 
      optionen <- ggplot2::theme(axis.text.y = element_blank(), 
                                 axis.title.y = element_blank(), axis.ticks.y = element_blank())
    teilsatz$from <- (teilsatz$from/(10^6))
    teilsatz$to <- (teilsatz$to/(10^6))
    #Choose manual colors
    if (c("EU") %in% unique(teilsatz$group) & c("JPM") %in% unique(teilsatz$group) ) { 
      col_scal=c("#0000ff","#fa8775","#cd34b5", "#000000") #EU, GB. GB?, JPM
    } else if (c("EU") %in% unique(teilsatz$group) & !(c("JPM") %in% unique(teilsatz$group)) ) {
      col_scal=c("#0000ff","#fa8775","#cd34b5") #EU, GB. GB?
    } else if (!(c("EU") %in% unique(teilsatz$group)) & c("JPM") %in% unique(teilsatz$group) ){
      col_scal=c("#fa8775","#cd34b5", "#000000") #GB. GB?, JPM
    }
    row.names(teilsatz) <- NULL
    teilsatz$id <- as.factor(teilsatz$id)
    teilsatz$id <- factor(teilsatz$id, levels = unique(teilsatz$id[order(teilsatz$NEWID)]))
    p <- ggplot2::ggplot(teilsatz)
    p <- p + ggplot2::geom_segment(data = teilsatz, aes(x = from, 
                                                        y = id, xend = to, yend = id, colour = as.factor(group)), 
                                   alpha = alfa, size = grosse)
    p <- p + ggplot2::xlim(0, max(teilsatz$to)) + ggplot2::ggtitle(paste("Chromosome ", 
                                                                         chromosome))
    p <- p + ggplot2::scale_color_manual(values=col_scal)
    p <- p + ggplot2::guides(colour = guide_legend(title = "Population")) + 
      ggplot2::xlab("Mbps") + theme_bw()
    p <- p + theme(plot.title = element_text(hjust = 0.5))
    p <- p + optionen
    if (savePlots & separatePlots) {
      if (!is.null(outputName)) {
        fileNameOutput <- paste(outputName, "Chr", chromosome, 
                                ".pdf", sep = "_")
      }
      else {
        fileNameOutput <- paste("Chr", chromosome, ".pdf", 
                                sep = "_")
      }
      ggsave(filename = fileNameOutput, plot = p, device = "pdf")
    }
    else if (savePlots) {
      plot_list[[chromosome]] <- p
    }
    else {
      print(p)
    }
  }
  if (savePlots & !separatePlots) {
    if (!is.null(outputName)) {
      fileNameOutput <- paste(outputName, "AllChromosomes.pdf", 
                              sep = "_")
    }
    else {
      fileNameOutput <- "Runs_AllChromosome.pdf"
    }
    plot_list_final <- gridExtra::marrangeGrob(plot_list, 
                                               nrow = 1, ncol = 1)
    ggsave(filename = fileNameOutput, plot = plot_list_final, 
           device = "pdf")
  }
}

#combine datasets for plotting

allRunsNoZ <- rbind(hRuns_noZ, mRuns_noZ)
#plotting runs along chromosomes
plot_Runs_mod(runs=allRunsNoZ)

#plot fROH across time
#read in info file
info <- read_delim("/storageToo/PROJECTS/Saad/repos/BVWpaper/infofile.tsv", delim="\t", col_types = cols())
FROH_class <- summaryList$result_Froh_class
FROH_class <- FROH_class %>% rename("sample_name" = "id")
FROH_df <- inner_join(FROH_class, info, by="sample_name")

FROH_df %>% 
  filter(Region=="GB") %>%
  ggplot(aes(x=year, y=Froh_Class_0.1)) +
  geom_point(size=3) +  #scale_fill_manual(values=c("#ffb14e", "#fa8775","#ea5f94", "#cd34b5", "#aca7a7"))+
  theme_bw()  + xlab("Year") + ylab("FROH 200 kb") + geom_smooth(method='lm') +
  geom_text_repel(aes(label = sample_name), size = 3, max.overlaps = 30)+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) 
  
  #geom_point(aes(x=1908, y=0.08265762, color="blue")) #adding japanese point manually

#plot FROH between groups
FROH_df %>% 
  ggplot(aes(x=Region, y=Froh_Class_0.1)) +
  geom_boxplot() +geom_jitter()+ #scale_fill_manual(values=c("#ffb14e", "#fa8775","#ea5f94", "#cd34b5", "#aca7a7"))+
  theme_bw()  + xlab("Region") + ylab("FROH 100 kb") + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

wilcox.test(Froh_Class_0.1~Region, data=FROH_df)
t.test(Froh_Class_0.1~Region, data=FROH_df)