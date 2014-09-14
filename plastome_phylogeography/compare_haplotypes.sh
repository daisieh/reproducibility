#!/bin/bash

#### check to remove any files to paths that don't exist on this machine.
samplefile=samplefile.txt

# rm $samplefile
# gawk '$0 !~ /^#/' $1 |
# {
# while read line
# do
# arr=($line);
# if [ -f ${arr[2]} ];
# then
# echo $line
# echo $line >> $samplefile;
# fi
# done;
# };

gawk -F " " '{print $11"\t"$1"\t"$12}' $1 > $samplefile


for ref in $2/*
do
	filename=$(basename "$ref")
	refname="${filename%.*}"

	mkdir $refname
	#### $samplefile has a sample file with server, name, path
	while read line
	do
		cd $refname
		arr=($line);
		sample=${arr[1]}
		echo "processing $sample..."
		echo "using $ref as reference"

		python $REPOS/phylogenomics/python/bowtie_align.py -i $samplefile -r $ref -p 8 -n 2000000

		samtools mpileup -B -C50 -I -f $ref -u $sample.sorted.bam > $sample.bcf
		bcftools view -c $sample.bcf > $sample.vcf
		rm $sample.bcf
		cd ..
	done < $1
done
