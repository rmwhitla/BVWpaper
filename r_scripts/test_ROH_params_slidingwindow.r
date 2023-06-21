install.packages("dplyr")
install.packages("stringr")
install.packages("readr")
install.packages("purrr")
install.packages("patchwork")

library(purrr)
library(readr)
library(stringr)
library(ggplot2)
library(dplyr)
library(patchwork)

#comparison of homozyg-het value changes - 1, 3, 750. = max # of hets in ROH. all other values at default
ROH_25kb_homozyg_snp25=read_table("Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb25.homwinsnp100.homwinhet2.homwinmis10.homhet3.FROH_min_25kb_table.txt")

ROH_50kb_homozyg_snp25=read_table("Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb50.homwinsnp100.homwinhet2.homwinmis10.homhet3.FROH_min_50Kb_table.txt")

ROH_100kb_homozyg_snp25=read_table("Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb100.homwinsnp100.homwinhet2.homwinmis10.homhet3.FROH_min_100KB_table.txt")

ROH_25kb_homozyg_snp10=read_table("Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.hwe0.05.homsnp10.homkb25.homwinsnp100.homwinhet2.homwinmis10.homhet3.FROH_min_25kb_table.txt")

ROH_50kb_homozyg_snp10=read_table("Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.hwe0.05.homsnp10.homkb50.homwinsnp100.homwinhet2.homwinmis10.homhet3.FROH_min_50kb_table.txt")

ROH_100kb_homozyg_snp10=read_table("Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.hwe0.05.homsnp10.homkb100.homwinsnp100.homwinhet2.homwinmis10.homhet3.FROH_min_100kb_table.txt")


ROH_25kb_homozyg_snp25$ROHparam <- rep("Min. ROH 25KB, min. SNP count 25", dim(ROH_25kb_homozyg_snp25)[1] )
ROH_50kb_homozyg_snp25$ROHparam <- rep("Min. ROH 50KB, min. SNP count 25", dim(ROH_50kb_homozyg_snp25)[1] )
ROH_100kb_homozyg_snp25$ROHparam <- rep("Min. ROH 100KB, min. SNP count 25", dim(ROH_100kb_homozyg_snp25)[1] )
ROH_25kb_homozyg_snp10$ROHparam <- rep("Min. ROH 25KB, min. SNP count 10", dim(ROH_25kb_homozyg_snp10)[1] )
ROH_50kb_homozyg_snp10$ROHparam <- rep("Min. ROH 50KB, min. SNP count 10", dim(ROH_50kb_homozyg_snp10)[1] )
ROH_100kb_homozyg_snp10$ROHparam <- rep("Min. ROH 100KB, min. SNP count 10", dim(ROH_100kb_homozyg_snp10)[1] )

kbtests <- rbind(ROH_25kb_homozyg_snp25, ROH_50kb_homozyg_snp25, ROH_100kb_homozyg_snp25, ROH_25kb_homozyg_snp10, ROH_50kb_homozyg_snp10, ROH_100kb_homozyg_snp10)





kbtests %>%
  ggplot(aes(x = sample, y = as.numeric(FROH))) +
  geom_col() +
  facet_wrap(~ROHparam) +
  ylim(0,0.5) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90)) +
  ggtitle("FROH changes with min ROH size")+
  xlab("Samples") +
  ylab("Froh")


kbtests %>%
  ggplot()+
  geom_col(aes(x=sample, y=as.numeric(FROH), fill=ROHparam), position='dodge', alpha = 0.9)+
  theme(axis.text.x = element_text(angle = 90)) +
  ggtitle("FROH changes with min ROH size")+
  xlab("Samples")+
  ylab("FROH")+
  ylim(0,0.3)+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
  


ROH_window25=read_table("Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb50.homwinsnp25.homwinhet2.homwinmis10.homhet3.FROH_min_50kb_table.txt")
ROH_window50=read_table("Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb50.homwinsnp50.homwinhet2.homwinmis10.homhet3.FROH_min_50kb_table.txt")
ROH_window100=read_table("Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb50.homwinsnp100.homwinhet2.homwinmis10.homhet3.FROH_min_50Kb_table.txt")


ROH_window25$ROHparam <- rep("Sliding window 25 SNP", dim(ROH_window25)[1] )
ROH_window50$ROHparam <- rep("Sliding window 50 SNP", dim(ROH_window50)[1] )
ROH_window100$ROHparam <- rep("Sliding window 100 SNP", dim(ROH_window100)[1] )

windowtests <- rbind(ROH_window25, ROH_window50, ROH_window100)

windowtests %>%
  ggplot()+
  geom_col(aes(x=sample, y=as.numeric(FROH), fill=ROHparam), position='dodge', alpha = 0.9)+
  theme(axis.text.x = element_text(angle = 90)) +
  ggtitle("FROH changes with sliding window size")+
  xlab("Samples")+
  ylab("FROH")+
  ylim(0,0.9)+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

