#!/bin/bash

#Calculates nucleotide diveristy  in sliding windows by
#1. Splitting a megreged vcf file by Pop (both vcf and pop files need to be provided)
#2. Estimates nucleotide diversity across both populations

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#SETUP

VCF=/storage/PROJECTS/Rebecca/GenErodeResults/GenErode/050includedresults/historical/vcf/Aporia_crataegi-GCA_912999735.1-softmasked.historical.merged.biallelic.fmissing0.1.vcf.gz

#Modern samples not included here
GB=/storageToo/PROJECTS/Saad/repos/BVWpaper/samplesGB.txt  #samples belonging to GB only
EUR=/storageToo/PROJECTS/Saad/repos/BVWpaper/samplesEU.txt  #samples assigned to European PopS
#OUTPUT
OUT_DIR=/storageToo/PROJECTS/Saad/repos/BVWpaper/pi_out

#Make VCF for GB and EU samples only
#Activate conda environment or have BCFtools in path
eval "$(conda shell.bash hook)"
conda activate bcftoolfs1.16 
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Split vcf by pop

bcftools view -S $GB  -o $OUT_DIR/GB.vcf  $VCF
bcftools view -S $EUR  -o $OUT_DIR/EUR.vcf  $VCF

#Calculate Nucleotide Diversity from ensuing files
vcftools --vcf $OUT_DIR/GB.vcf --window-pi 10000 --out $OUT_DIR/A_crataegi_hist_GB_10kb
vcftools --vcf $OUT_DIR/EUR.vcf --window-pi 10000 --out $OUT_DIR/A_crataegi_hist_EUR_10kb




