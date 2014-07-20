#!/bin/bash

# Salicaceae rrna phylogeny, Athaliana reference.

if [ -n $REPOS ];
then
REPOS=$HOME;
fi

# a file with the list of samples:
#1DNA	2samplename	3aTRAM	4server	5BAMpath
INFILE=salicaceae

RESULTDIR=rrna_results
OUTNAME=$RESULTDIR/$INFILE

mkdir $RESULTDIR

# OUTNAME.1.txt has server,sample,path
gawk -F " " '{print $2"\t"$3}' $INFILE.txt > $OUTNAME.samples.txt
printf "Ath_rrna\tAth_rrna.fasta\n" > $OUTNAME.targets.txt

perl $REPOS/aTRAM/Pipelines/AlignmentPipeline.pl -samples $OUTNAME.samples.txt -targets $OUTNAME.targets.txt -frac 0.5 -output $OUTNAME.atram
