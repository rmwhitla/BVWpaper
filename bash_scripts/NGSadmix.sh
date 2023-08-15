#!/bin/bash


#Takes in a list of bam files and then
#1. converts to genotype likelihood in Beagle format
#2. Performs NGSadmix


############################
#PATHS : change for your system
#ANGSD_PATH=
OUT_DIR=/storageToo/PROJECTS/Saad/repos/BVWpaper/angsd_out
###########################

INBAMS=$1 # command line arguement list of full paths to all BAMS

#Step 1
angsd -GL 2 -out $OUT_DIR/genolike -nThreads 16 -doGlf 2 -doMajorMinor 1 -SNP_pval 1e-6 -uniqueOnly 1 -doMaf 2 \
	-minMapQ 30 -minQ 20 -skipTriallelic 1 -minMaf 0.1 -doDepth 1 -doCounts 1 -bam $INBAMS

#step 2
NGSadmix -minMaf 0.1 -likes  $OUT_DIR/genolike.beagle.gz -K 2 -seed 1 -P 10 -o $OUT_DIR/NGSAdmix
