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
echo $line > $sample.txt
ref=$sample.plastome.final.fasta

python $REPOS/phylogenomics/python/bowtie_align.py -i $sample.txt -r $ref -p 8 -n 50000000

samtools mpileup -B -C50 -f $ref -u $sample.sorted.bam > $sample.bcf
bcftools view -c $sample.bcf > $sample.vcf
rm $sample.bcf

done < $samplefile
