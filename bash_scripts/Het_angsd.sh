#!/bin/bash

#A script to calcualte heterozygsity from bam file using ANGSd (using genotype likelelihoods
#Input a list of BAM files

#the reference location and output location should also be set
REF=/storage/PROJECTS/Rebecca/genomes/Aporia_crataegi-GCA_912999735.1-softmasked.fa
OUTDIR=/storageToo/PROJECTS/Saad/repos/BVWpaper/angsd_het 

#angsd and realSFS should be in your path

BAMFILE=$1 # user suppliet path to all BAM files

while read -r BAM
do	
	#get sample name
	TMP=$(basename ${BAM}) # get file name only
	SAMPLE=${TMP%%.*}  # get prefix before first dot, use this prefix for output files
	echo $SAMPLE
	#Step 1. Run angsd to filter and call genotype likelihoods
	angsd -P 8 -i $BAM -anc $REF -out $OUTDIR/$SAMPLE -dosaf 1 -uniqueOnly 1 -ref $REF -C 50 -baq 1 -minMapQ 30 -minQ 20 -GL 2
	#step 2. Calulcate the folded SFS 
	realSFS -P 8 -fold 1  -maxIter 100 $OUTDIR/$SAMPLE.saf.idx > $OUTDIR/$SAMPLE.est.ml
done < $BAMFILE
