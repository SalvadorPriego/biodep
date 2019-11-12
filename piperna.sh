## This pipeline analysis RNA-seq data

## Author: Antonio Melgar
## Contact: melgar.cruz.antonio@gmail.com

#! /bin/bash

if [ $# -eq 0 ]
then
  echo "This pipeline analysis RNA-seq data"
  echo "Usage: piperna <param_file>"
  echo ""
  echo "param_file: File with the paramenters specification. Please, check test/params.txt for an example"

exit 0
fi

## Parameters loading
PARAMS=$1

WD=$(grep working_directory: $PARAMS | awk '{ print $2}' )
NS=$(grep number_of_samples: $PARAMS | awk '{ print $2}' )
GENOME=$(grep genome: $PARAMS | awk '{ print $2}' )
ANNOTATION=$(grep annotation: $PARAMS | awk '{ print $2}' )

SAMPLES=( )
I=0
while [ $I -lt $NS ]
do
  SAMPLES[$I]=$(grep sample_$(($I+1)): $PARAMS | awk '{ print $2}' )
  ((I++)) 
done
echo "WD=$WD"
echo "NS=$NS"

## Generate working directory
mkdir $WD
cd $WD
mkdir genome annotation results samples logs
cd samples
I=1
while [ $I -le $NS ]
do 
   mkdir sample_$I
   ((I++))
done

## Generate genome index
cd $WD/genome
cp $GENOME genome.fa

cd ../annotation
cp $ANNOTATION annotation.gtf

extract_splice_sites.py annotation.gtf > splice.ss
extract_exons.py annotation.gtf > exons.exon

cd ../genome
hisat2-build --ss ../annotation/splice.ss --exon ../annotation/exons.exon genome.fa index

## Copy samples
cd $WD/samples

I=0
while [ $I -lt $NS ]
do
  cp ${SAMPLES[$I]} sample_$(($I+1))/sample_$(($I+1)).fastq.gz
   ((I++))
done

I=1
while [ $I -lt $NS ]
do
  qsub -N sample_$I -o $WD/logs/sample_$I rna_seq_sample_processing.sh $I $WD $NUM_SAMPLES

done
