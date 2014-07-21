#!/bin/bash

# sample file has host sample path
SAMPLE=$1

# pairwise fasta for "genome"
FASTA=$2
bwa index $FASTA

python $REPOS/phylogenomics/python/bwa_to_bam.py -i $SAMPLE -r $FASTA -p 8 -n 50000000

# remove unmapped pairs
samtools view -F 4 -b $samplename.bam > $samplename.reduced.bam

# sort the bam files
while read line
do
arr=($line);
samplename=${arr[1]};
samtools sort $samplename.reduced.bam $samplename.sorted
done < $SAMPLE
