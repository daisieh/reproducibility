#!/bin/bash

#### check to remove any files to paths that don't exist on this machine.
samplefile="samplefile.txt"

for ref in $2/*
do
	mkdir $ref
	cd $ref
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
	echo "using $ref as reference"

	python $REPOS/phylogenomics/python/bowtie_align.py -i $sample.txt -r $ref -p 8 -n 2000000

	samtools mpileup -B -C50 -I -f $ref -u $sample.sorted.bam > $sample.bcf
	bcftools view -c $sample.bcf > $sample.vcf
	rm $sample.bcf
	cd ..
	done < $samplefile
done
