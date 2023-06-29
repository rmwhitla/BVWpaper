#Plot results for pi using VCFtools

library(ggplot2)
library(dplyr)
library(gridExtra)

#Data Import
#pi files need to be generated, not tracked
pi.GB <- read.table("../bash_scripts/A_crataegi_hist_GB_10kb.windowed.pi",header=T)
pi.EU <- read.table("../bash_scripts/A_crataegi_hist_EUR_10kb.windowed.pi",header=T)

#remove Z
pi.GB.auto <- pi.GB[pi.GB$CHROM != "Z",]
pi.GB.auto$CHROM <- as.numeric(pi.GB.auto$CHROM)
pi.EU.auto <- pi.EU[pi.EU$CHROM != "Z",]
pi.EU.auto$CHROM <- as.numeric(pi.EU.auto$CHROM)
#######################################################################
#Plotting

#calculate cumulative position of each SNP

pi.GB.auto_cum <- pi.GB.auto %>% 
  
  # Compute chromosome size
  group_by(CHROM) %>% 
  summarise(chr_len=max(BIN_END)) %>% 
  
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  
  # Add this info to the initial dataset
  left_join(pi.GB.auto, ., by=c("CHROM"="CHROM")) %>%
  
  # Add a cumulative position of each SNP
  arrange(CHROM, BIN_START) %>%
  mutate( BPcum=BIN_START+tot)
#prepare xaxis
axisdf = pi.GB.auto_cum %>% group_by(CHROM) %>% summarize(center=( max(BPcum) + min(BPcum) ) / 2 )

#make the plot
gb <- ggplot(pi.GB.auto_cum, aes(x=BPcum, y=PI)) +
  
  # Show all points
  geom_point( aes(color=as.factor(CHROM)), alpha=0.8, size=1.3) +
  scale_color_manual(values = rep(c("grey", "#000000"), 22 )) +
  
  # custom X axis:
  scale_x_continuous( label = axisdf$CHROM, breaks= axisdf$center ) +
  scale_y_continuous(expand = c(0, 0) ) + ylim(c(0,0.00075))  +  # remove space between plot area and x axis
  xlab("") + ylab(expression(paste(pi, " nucleotide diversity"))) +
  ggtitle("(a) Great Britian") + 
  # Custom the theme:
  theme_bw() +
  theme( plot.title = element_text(hjust = 0.5),
    legend.position="none",
    panel.border = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )



##Do the same for EU
#calculate cumulative position of each SNP

pi.EU.auto_cum <- pi.EU.auto %>% 
  
  # Compute chromosome size
  group_by(CHROM) %>% 
  summarise(chr_len=max(BIN_END)) %>% 
  
  # Calculate cumulative position of each chromosome
  mutate(tot=cumsum(chr_len)-chr_len) %>%
  select(-chr_len) %>%
  
  # Add this info to the initial dataset
  left_join(pi.EU.auto, ., by=c("CHROM"="CHROM")) %>%
  
  # Add a cumulative position of each SNP
  arrange(CHROM, BIN_START) %>%
  mutate( BPcum=BIN_START+tot)
#prepare xaxis
axisdf = pi.EU.auto_cum %>% group_by(CHROM) %>% summarize(center=( max(BPcum) + min(BPcum) ) / 2 )

#make the plot
eu <- ggplot(pi.EU.auto_cum, aes(x=BPcum, y=PI)) +
  
  # Show all points
  geom_point( aes(color=as.factor(CHROM)), alpha=0.8, size=1.3) +
  scale_color_manual(values = rep(c("grey", "#000000"), 22 )) +
  
  # custom X axis:
  scale_x_continuous( label = axisdf$CHROM, breaks= axisdf$center ) +
  scale_y_continuous(expand = c(0, 0) ) +   ylim(c(0,0.00075))  +  # remove space between plot area and x axis
  xlab("Chromosome") + ylab(expression(paste(pi, " nucleotide diversity"))) +
  ggtitle("(b) Europe") + 
  # Custom the theme:
  theme_bw() +
  theme( plot.title = element_text(hjust = 0.5),
    legend.position="none",
    panel.border = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )

grid.arrange(gb, eu, nrow = 2)
