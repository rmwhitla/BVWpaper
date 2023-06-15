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
ROH_homozyg_het_750=read_table("Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb100.homwinsnp100.homwinhet2.homwinmis10.homhet750.FROH_min_100KB_table.txt")

ROH_homozyg_het_1=read_table("Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb100.homwinsnp100.homwinhet2.homwinmis10.homhet1.FROH_min_100kb_table.txt")

ROH_homozyg_het_3=read_table("Aporia_crataegi-GCA_912999735.1-softmasked.all.merged.biallelic.fmissing0.1.hwe0.05.homsnp25.homkb100.homwinsnp100.homwinhet2.homwinmis10.homhet3.FROH_min_100KB_table.txt")



ROH_homozyg_het_1$ROHparam <- rep("1 Heterozygote/ROH", dim(ROH_homozyg_het_1)[1] )
ROH_homozyg_het_3$ROHparam <- rep("3 Heterozygotes/ROH", dim(ROH_homozyg_het_3)[1] )
ROH_homozyg_het_750$ROHparam <- rep("750 Heterozygotes/ROH", dim(ROH_homozyg_het_750)[1] )

hhtests <- rbind(ROH_homozyg_het_1, ROH_homozyg_het_3, ROH_homozyg_het_750)





hhtests %>%
  ggplot(aes(x = sample, y = as.numeric(FROH))) +
  geom_col() +
  facet_wrap(~ROHparam) +
  ylim(0,0.5) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90)) +
  ggtitle("FROH changes with homozyg-het-params")+
  xlab("Samples") +
  ylab("Froh")


hhtests %>%
  ggplot()+
  geom_col(aes(x=sample, y=as.numeric(FROH), fill=ROHparam), position='dodge', alpha = 0.6)+
  theme(axis.text.x = element_text(angle = 90)) +
  ggtitle("Changes in FROH by max hets allowed per ROH (homozyg-het param)")+
  xlab("Samples")+
  ylab("FROH")+
  ylim(0,0.3)+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
  





