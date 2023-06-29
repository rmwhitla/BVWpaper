#!/bin/bash

#Calculates nucleotide diveristy  in sliding windows by
#1. Splitting a megreged vcf file by Pop (both vcf and pop files need to be provided)
#2. Estimates nucleotide diversity across both populations

#Split vcf my population

VCF=/storage/PROJECTS/Rebecca/GenErodeResults/GenErode/results/historical/vcf/Aporia_crataegi-GCA_912999735.1-softmasked.historical.merged.biallelic.fmissing0.1.vcf.gz
#Modern samples not included here
GB=/storageToo/PROJECTS/Saad/repos/BVWpaper/samplesGB.txt  #samples belonging to GB only
EUR=/storageToo/PROJECTS/Saad/repos/BVWpaper/samplesEU.txt  #samples assigned to European PopS

#Make VCF for GB and EU samples only
#Activate conda environment or have BCFtools in path
eval "$(conda shell.bash hook)"
conda activate bcftoolfs1.16 

bcftools view -S $GB  -o GB.vcf  $VCF
bcftools view -S $EUR  -o EUR.vcf  $VCF

#Calculate Nucleotide Diversity from ensuing files
vcftools --vcf GB.vcf --window-pi 10000 --out A_crataegi_hist_GB_10kb
vcftools --vcf EUR.vcf --window-pi 10000 --out A_crataegi_hist_EUR_10kb




