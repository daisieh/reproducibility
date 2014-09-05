#!/bin/bash

#### check to remove any files to paths that don't exist on this machine.
samplefile="samplefile.txt"

rm $samplefile
gawk '$0 !~ /^#/' $1 |
{
while read line
do
arr=($line);
if [ -f ${arr[2]} ];
then
echo $line >> $samplefile;
fi
done;
};

#### $samplefile has a sample file with server, name, path
while read line
do
arr=($line);
sample=${arr[1]}
echo "processing $sample..."
echo "  making fasta from bam"
echo $line > $sample.txt
ref=$sample.plastome.final.fasta
bwa index $ref
python ~/phylogenomics/python/bwa_to_bam.py -i $sample.txt -r $ref -p 8 -n 10000000
python ~/phylogenomics/python/bam_to_vcf.py -i $sample.txt -r $ref -p 8

done < $samplefile
