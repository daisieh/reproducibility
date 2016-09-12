#!/bin/bash

cd /Volumes/Pantry2/

while read line
do
arr=($line);
samplename=${arr[2]};
echo $samplename

# samples/concat_samples/$samplename.1.fq
gzip -dc samples/concat_samples/$samplename.1.fq.gz > cp/$samplename.1.fq 
gzip -dc samples/concat_samples/$samplename.1.fq.gz > cp/$samplename.2.fq 
cd cp
bwa aln reference.fasta $samplename.1.fq > $samplename.1.sai
bwa aln reference.fasta $samplename.2.fq > $samplename.2.sai
bwa sampe reference.fasta $samplename.1.sai $samplename.2.sai $samplename.1.fq $samplename.2.fq > $samplename.sam
rm $samplename.1.sai
rm $samplename.2.sai
rm $samplename.1.fq
rm $samplename.2.fq
samtools view -S -b -u -o $samplename.bam $samplename.sam
samtools view -F 4 -b $samplename.bam > $samplename.reduced.bam
rm $samplename.sam
rm $samplename.bam
mv $samplename.reduced.bam $samplename.bam
samtools sort $samplename.bam $samplename.sorted

cd ..

done < /Volumes/Pantry2/all_barcodes.txt
