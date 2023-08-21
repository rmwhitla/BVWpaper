#!/bin/bash


#Takes in a list of beagle file with gt likelihoods previously produced by angsd, see PCA_angsd.sh
#1. Performs NGSadmix for given K
#2. Peforms NGS admix for K1-5 for 6 reps to choose best K - change range of K and reps in step 3 manually


############################
#PATHS : change for your system
#ANGSD_PATH=
OUT_DIR=/storageToo/PROJECTS/Saad/repos/BVWpaper/angsd_out
###########################

BEAGLE=$1 # command line arguement list of beagle file from angsd
K=$2 #command line argeument for value of K 

#step 1
#NGSadmix -minMaf 0.1 -likes  $BEAGLE -K $K -seed 1 -P 12 -o $OUT_DIR/NGSAdmix_0.1.missing.K${K}

#step 2: Run 6 reps for K1-5 to choose K
for k in {1..5}; do
	for rep in {1..10}; do
		NGSadmix -minMaf 0.1 -likes  $BEAGLE -K $k  -P 10 -o $OUT_DIR/NGSAdmix_0.1.missing.K${k}_${rep}
	done;
done;
