#!/bin/bash

#### $samplefile has a sample file with server, name, path

CWD=$(pwd)
cd $(dirname "$1")
samplefile=$(pwd)/$(basename "$1")
cd $CWD


REFS=$2/*.fasta
results=results
mkdir $results

for ref in $REFS
do
	filename=$(basename "$ref")
	refname="${filename%.*}"
	echo "$refname"
	echo -e "sample\t$refname" > $results/$refname.$results.txt

	cd $CWD/$refname
	#for vcffile in $vcfs
	while read line
	do
		arr=($line);
		sample=${arr[1]}
		if [ -f $sample.vcf ]
		then
			echo "counting snps in $sample"
			perl $REPOS/phylogenomics/analysis/count_SNPs.pl -sample $sample.vcf >> $CWD/$results/$refname.$results.txt
		fi
	done < $samplefile
	cd $CWD
done

cd $CWD
REFS=$results/*
refline=$(echo $REFS)
perl $REPOS/phylogenomics/converting/combine_files.pl -head -names -in $refline > $samplefile.$results.txt
# perl $REPOS/reproducibility/plastome_phylogeography/closest_ref.pl $samplefile.$results.txt > $samplefile.refs.txt
