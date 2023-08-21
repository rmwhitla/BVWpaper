#!/bin/bash

#A script to perform PCA of hard genotypes,excluding Z chromosome using Plink
#INPUT should be final vcf from Generode output
#User neeeds to specify:
#1: Input VCF file
#2: Minor allele frequency to use as cut-off

#Requires:
#1: vcftools
#2: plink

INVCF=$1
MAF=$2

OUTDIR=/storageToo/PROJECTS/Saad/repos/BVWpaper/plink_pca_out
TMP=$(basename ${INVCF})
OUTNAME=${TMP%%-*}

#Step 1: filter on MAF
vcftools --gzvcf $INVCF --maf $MAF --recode --not-chr Z --out  $OUTDIR/${OUTNAME}_maf_${MAF}.vcf 

#step 2: do the pca
/opt/plink --vcf $OUTDIR/${OUTNAME}_maf_${MAF}.vcf.recode.vcf --double-id --allow-extra-chr --pca --set-missing-var-ids @:#  --out $OUTDIR/${OUTNAME}_maf_${MAF}
