#!/bin/bash


#Takes ins a list of bam file sn then
#1. converts to genotype likelihood in Beagle format
#2. PCAangsd makes a covairance matrix from likelihoods that can be used for PCA


############################
#PATHS
ANGSD=/opt/angsd/angsd
###########################

INBAMS=$1 # command line arguement list of full paths to all BAMS

#Step 1
$ANGSD -GL 2 -out genolike -nThreads 10 -doGlf 2 -doMajorMinor 1 -SNP_pval 1e-6 -uniqueOnly 1 -doMaf 2 -minMapQ 30 -minQ 20 -skipTriallelic 1 -minMaf 0.1 -doDepth 1 -doCounts 1 -bam $INBAMS

#step 2
pcangsd --minMaf 0.1 --beagle genolike.beagle.gz -o angsdPCA
