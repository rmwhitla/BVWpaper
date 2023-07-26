#! /bin/bash

#####HELP#########################################################################
Help()
{
	echo
	echo "*** input is required for this script to work! ***"
	echo
	echo "Usage:"
	echo "	Generates and runs psmc on a single bam file with average depth provided"
	echo "	"
	echo "	e.g. $0 BAM DEPTH MASKFILE OUTDIR"
	echo
	echo "Parameters:"
	echo 
	echo "  BAM= Path single BAM file for individual"
	echo "  MASKFILE= GENOME mask to exclude nonmappable regions - same for single species"
	echo "	OUTDIR= where to store the ouput files"
	echo "	"
	echo
	echo "Dependencies:"
	echo
	echo "	PSMC, bcftools, vcfutils.pl (samtools)"
	echo "	"
}
####################################################################################
#immediately stop on following  errors
set -o errexit
set -o nounset
set -o pipefail

#help option activated (-h)
while getopts ":h" option;do
	case $option in
		h) #display help
		  Help
		  exit;;
	       \?) # incorret option
		  echo "Error: invalid option"
		  exit;;
	esac
done

#Default values of inputs
BAM=${1:?Variable not set or empty} #fail if BAM is not provided
MASK=${3:-./FinalMappabilityMask/Picarus.1-22.finalmask.bed.gz} #change this as required  and provide full path
DIR=${4:-./psmc_out} #top level output directory created, change location as required and give full path

#Ref genome CHANGE AS NECESSARY, full path
GENOME=./REFS/Polyommatus_icarus-GCA_937595015.1-softmasked.fa
#lcoation of reference with index

#Make out directory if it doesn't exist
mkdir -p $DIR 
#Safe BAM prefix for output file
TMP=$(basename ${BAM}) # get file name only
NAME=${TMP%%.*}  # get prefix before first dot, use this prefix for output files
mkdir -p  ${DIR}/${NAME}
#####################################################################
#PATHs
psmc=/opt/psmc/psmc
#Also need BCFtools in path
######################################################################

#DEPTH
#It is recommended to set minDP to a third of the average depth and maxDP to twice.
#The following arithmetical is integer
minDP=5
#minDP=10
maxDP=20

echo ${minDP} ${maxDP}
${bcftools}/bcftools mpileup -C 50 -q 20 -Q 20 -R $MASK -f ${GENOME} ${BAM} | \
${bcftools}/bcftools call -c -V indels | vcfutils.pl vcf2fq -d ${minDP} -D ${maxDP} > ${DIR}/${NAME}/${NAME}.psmc.fq
#-C: adjust mapping quality; 
#-q: determine the cutoffs for mapQ
#-u: generate uncompressed VCF output
#-f: the reference fasta used (needs to be indexed)

#Convert fastq files to the input format for PSMC
${psmc}/utils/fq2psmcfa -q20 ${DIR}/${NAME}/${NAME}.psmc.fq > ${DIR}/${NAME}/${NAME}.psmcfa
${psmc}/psmc -N25 -t15 -r5 -p "28*2+3+5" -o ${DIR}/${NAME}/${NAME}.psmc  ${DIR}/${NAME}/${NAME}.psmcfa 
#-N: maximum number of iterations
#-t: maximum 2N0 coalescent time
#-r: initial theta/rho ratio
#-p: pattern of parameters
#the `-p' and `-t' options are manually chosen such that after 20 rounds of iterations

#visualize the population size history
#CHANGE AS REQ
GEN=1 # generations per year
mu=2.9e-09 #spontanouesa mutation rate mu or alternatively 1.9e-09
cd ${DIR}/${NAME}
${psmc}/utils/psmc_plot.pl -g $GEN -R -x 1000 -X 5000000 -Y 600 -u $mu  ${NAME} ${NAME}.psmc
#The plot may not work but it should create a file that can be used for plotting in R

#Peform 100 boot strap
#randomly sampling with replacement 5-Mb sequence segments
$psmc/utils/splitfa ${DIR}/${NAME}/${NAME}.psmcfa > ${DIR}/${NAME}/${NAME}.split.psmc.fa
	
#Convert fastq files to the input format for 100 bootstrap replicates of PSMC
seq 100 | xargs -i echo  $psmc/psmc -N25 -t15 -r5 -b -p "28*2+3+5" -o ${DIR}/${NAME}/${NAME}.round-{}.psmc ${DIR}/${NAME}/${NAME}.split.psmc.fa | sh
	
#merge all PSMC results including 100 bootstrap replicates for each sample
cat ${DIR}/${NAME}/${NAME}.psmc ${DIR}/${NAME}/${NAME}.round-{}.psmc > ${DIR}/${NAME}/${NAME}.100bootstrap.psmc

#generate plotting file
${psmc}/utils/psmc_plot.pl -g $GEN -R -x 1000 -X 5000000 -Y 600 -u $mu  ${NAME} ${NAME}.100bootstrap.psmc
#Finish plotting in R
