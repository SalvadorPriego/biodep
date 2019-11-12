##Author: Antonio Melgar de la Cruz
##Contact: melgar.cruz.antonio@gmail.com

#! /bin/bash

##Reading input parameters
SAMPLE_ID=$1
WD=$2
NUM_SAMPLES=$3
##Access sample folder
cd $WD/samples/sample_${SAMPLE_ID}

##QC
fastqc sample_${SAMPLE_ID}.fq.gz

##Mapping to reference genome
hisat2 --dta -x $WD/genome/index -U sample_${SAMPLE_ID}.fq.gz -S sample_${SAMPLE_ID}.sam
samtools sort -o sample_${SAMPLE_ID}.bam sample_${SAMPLE_ID}.sam
rm sample_${SAMPLE_ID}.sam
##Transcript assembly
stringtie -G $WD/annotation/annotation.gtf -o sample_${SAMPLE_ID}.gtf -l sample_${SAMPLE_ID} sample_${SAMPLE_ID}.bam
##Synchronization point through blackboards
echo sample_${SAMPLE_ID} "DONE" >> $WD/logs/blackboard

DONE_SAMPLES=$(wc -l $WD/logs/blackboard)

if [ ${DONE_SAMPLES} -eq ${NUM_SAMPLES} ]
then
  qsub 
fi
