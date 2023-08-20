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
regions_file=/storageToo/PROJECTS/Saad/repos/BVWpaper/angsd_region_excludeZ.txt #excludes Z

#Step 1
angsd -GL 2  -nThreads 12 -doGlf 2 -doMajorMinor 1 -SNP_pval 1e-6 -uniqueOnly 1 \
	-doMaf 2 -minMapQ 30 -minQ 20 -skipTriallelic 1 -doDepth 1 -doCounts 1 \
	-rf $regions_file -out $OUT_DIR/genolike_0.1.missing -minInd 15 -bam $INBAMS

#step 2
pcangsd --threads 12 --minMaf 0.1 --beagle $OUT_DIR/genolike_0.1.missing.beagle.gz -o $OUT_DIR/angsdPCA_0.1.missing
