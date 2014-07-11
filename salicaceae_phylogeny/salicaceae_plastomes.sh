#!/bin/bash

# Salicaceae plastome phylogeny, Manihot reference.

if [ -n $REPOS ];
then
REPOS="~";
fi

# a file with the list of samples:
#1DNA	2samplename	3aTRAM	4server	5BAMpath
INFILE=samples.txt

RESULTDIR=results
OUTNAME=$RESULTDIR/$INFILE

mkdir $RESULTDIR

# run the bam to vcf pipeline:
# OUTNAME.1.txt has sample,server,path
gawk -F "\t" 'NR > 1 {print $2,$4,$5}' $INFILE > $OUTNAME.1.txt
cd $RESULTDIR
bash $REPOS/phylogenomics/pipelines/bam_to_plastome_vcf.sh $OUTNAME.1.txt Manihot_cp.fasta
cd ..

# convert the vcfs to fasta:
gawk -F "\t" 'NR > 1 {print $1".vcf"}' $INFILE > $OUTNAME.2.txt
perl $REPOS/phylogenomics/converting/vcf2fasta.pl -samples $OUTNAME.2.txt -output $OUTNAME -thresh 0 -cov 300

# trim missing data at the 0.1 missing threshold:
perl $REPOS/phylogenomics/parsing/trim_missing.pl -in $OUTNAME.fasta -out $OUTNAME.trimmed.fasta -row 1.0 -col 0.1
