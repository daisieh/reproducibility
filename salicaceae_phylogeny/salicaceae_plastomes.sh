#!/bin/bash

# Salicaceae plastome phylogeny, Manihot reference.

if [ -n $REPOS ];
then
REPOS=$HOME;
fi

# a file with the list of samples:
#1DNA	2samplename	3aTRAM	4server	5BAMpath
INFILE=samples.txt

RESULTDIR=results
OUTNAME=$RESULTDIR/$INFILE

mkdir $RESULTDIR

# check to remove any files to paths that don't exist on this machine.
while read line
do
arr=($line);
if [ -f ${arr[4]} ];
then
echo $line >> $OUTNAME.0.txt;
fi
done < $INFILE

INFILE=$OUTNAME.0.txt;

# run the bam to vcf pipeline:

# OUTNAME.1.txt has server,sample,path
gawk -F " " '{print $4"\t"$2"\t"$5}' $INFILE > $OUTNAME.1.txt

cp Manihot_cp.fasta $RESULTDIR/

cd $RESULTDIR
# index the Manihot file
bwa index Manihot_cp.fasta
bash $REPOS/phylogenomics/pipelines/bam_to_plastome_vcf.sh ../$OUTNAME.1.txt Manihot_cp.fasta
cd ..

# convert the vcfs to fasta:
gawk -F " " '{print $2".vcf"}' $INFILE > $OUTNAME.2.txt
perl $REPOS/phylogenomics/converting/vcf2fasta.pl -samples $OUTNAME.2.txt -output $OUTNAME -thresh 0 -cov 300

# trim missing data at the 0.1 missing threshold:
perl $REPOS/phylogenomics/parsing/trim_missing.pl -in $OUTNAME.fasta -out $OUTNAME.trimmed.fasta -row 1.0 -col 0.1
