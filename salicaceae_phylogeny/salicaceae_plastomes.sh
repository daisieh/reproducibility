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

# run the bam to vcf pipeline:

# OUTNAME.1.txt has server,sample,path
gawk -F " " '{print $4"\t"$2"\t"$5}' $OUTNAME.0.txt > $OUTNAME.1.txt

cp Manihot_cp.fasta $RESULTDIR/

cd $RESULTDIR
# index the Manihot file
bwa index Manihot_cp.fasta
bash $REPOS/phylogenomics/pipelines/bam_to_plastome_vcf.sh ../$OUTNAME.1.txt Manihot_cp.fasta
cd ..

# convert the vcfs to fasta:
gawk -F " " '{print $2".vcf"}' $OUTNAME.0.txt > $OUTNAME.2.txt
cd $RESULTDIR
perl $REPOS/phylogenomics/converting/vcf2fasta.pl -samples ../$OUTNAME.2.txt -output ../$OUTNAME -thresh 0 -cov 300
cd ..

# trim missing data at the 0.1 missing threshold:
perl $REPOS/phylogenomics/parsing/trim_missing.pl -in $OUTNAME.fasta -out $OUTNAME.trimmed -row 1.0 -col 0.1

# convert to phylip
perl $REPOS/phylogenomics/converting/convert_file.pl $OUTNAME.trimmed.fasta $OUTNAME.phy

# run RAxML
seed=$RANDOM
cd $RESULTDIR
raxmlHPC-PTHREADS -fa -s ../$OUTNAME.phy -x $seed -# 100 -m GTRGAMMA -n $seed -T 16 -p $seed
cd ..

# write the final tree to a nexus file:
printf "#NEXUS\n\nbegin TREES;\ntree best=\n" > $OUTNAME.tre;
cat RAxML_bipartitions.$seed >> $OUTNAME.tre;
printf "end;" >> $OUTNAME.tre;
