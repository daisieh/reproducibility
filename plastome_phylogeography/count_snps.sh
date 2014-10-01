#!/bin/bash

#### $samplefile has a sample file with server, name, path
samplefile=$1

REFS=$2/*

CWD=$(pwd)

for ref in $REFS
do
	filename=$(basename "$ref")
	refname="${filename%.*}"
	echo "$refname" > $refname.results.txt
	cd $CWD/$refname

	#for vcffile in $vcfs
	while read $line
	do
		arr=($line);
		sample=${arr[1]}
		if [ -f $sample.vcf ]
		then
			perl $REPOS/phylogenomics/analysis/count_SNPs.pl -sample $sample.vcf >> ../$refname.results.txt
		fi
	done < samplefile.txt
	cd $CWD
done
