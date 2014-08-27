#!/bin/bash

#### for each de novo sample:
reffile="trichocarpa_cp.gb"

for f in LAB13_DNA942 NWL1105_DNA778 RNA9_DNA1188 DEN13_DNA793
do
# python $REPOS/phylogenomics/python/subset_bam.py -i $SAMPLE -n 6 -p 4
#### use CLC genomics workbench 7.0.3 to do de novo assembly of the reads
#### rename the outputted contigs to more sensible names.
# sed s/\.small\.bam_.no_read_group._.paired.// < $f.contigs.fa | sed s/Average\ coverage:.*$// > $f.contigs.fasta

#### make draft plastome
perl $REPOS/phylogenomics/plastome/contigs_to_cp.pl -ref $reffile -contig $f.contigs.fasta -out $f.plastome

#### clean draft plastome
perl $REPOS/phylogenomics/plastome/clean_cp.pl -ref $reffile -contig $f.plastome.draft.fasta -out $f.plastome.clean.fasta


done;


#### aTRAM libs
# for f in LAB13_DNA942 NWL1105_DNA778 RNA9_DNA1188 DEN13_DNA793
# do
# bash $REPOS/phylogenomics/converting/bam_to_fasta.sh $f.small.bam $f
# perl $REPOS/aTRAM/format_sra.pl -in $f.fasta -out $f -num 10
#
# done;

