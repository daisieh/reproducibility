#!/bin/bash

#### $samplefile has a sample file with server, name, path
samplefile=$1

REFS=$2/*

CWD=$(pwd)

for ref in $REFS
do
	filename=$(basename "$ref")
	refname="${filename%.*}"
	echo "$refname"
	echo -e "sample\t$refname" > $refname.results.txt
	cd $CWD/$refname

	#for vcffile in $vcfs
	while read line
	do
		arr=($line);
		sample=${arr[1]}
		if [ -f $sample.vcf ]
		then
			echo "counting snps in $sample"
			perl $REPOS/phylogenomics/analysis/count_SNPs.pl -sample $sample.vcf >> $CWD/$refname.results.txt
		fi
	done < $CWD/$samplefile
	cd $CWD
done

echo "perl $REPOS/phylogenomics/converting/combine_files.pl -head -names -in $REFS > $samplefile.results.txt"
perl $REPOS/phylogenomics/converting/combine_files.pl -head -names -in $REFS > $samplefile.results.txt
perl $REPOS/reproducibility/plastome_phylogeography/closest_ref.pl $samplefile.results.txt
