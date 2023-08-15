#!/bin/bash


#Takes ins a list of bam file sn then
#1. converts to genotype likelihood in Beagle format
#2. PCAangsd makes a covairance matrix from likelihoods that can be used for PCA


############################
#PATHS : change for your system
#ANGSD=/opt/angsd/angsd
#PCANGSD=/opt/pcangsd/pcangsd/pcangsd.py
###########################

INBAMS=$1 # command line arguement list of full paths to all BAMS
OUT_DIR=/storageToo/PROJECTS/Saad/repos/BVWpaper/angsd_out

#Step 1
#$ANGSD -GL 2 -out genolike -nThreads 10 -doGlf 2 -doMajorMinor 1 -SNP_pval 1e-6 -uniqueOnly 1 -doMaf 2 -minMapQ 30 -minQ 20 -skipTriallelic 1 -minMaf 0.1 -doDepth 1 -doCounts 1 -bam $INBAMS

#step 2
pcangsd --minMaf 0.1 --beagle $OUT_DIR/genolike.beagle.gz -o $OUT_DIR/angsdPCA
