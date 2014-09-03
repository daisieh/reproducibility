#!/bin/bash

#### for each de novo sample:
reffile="trichocarpa_cp.gb"
samplefile=$1

#### $SAMPLE has a sample file with server, name, path
# python $REPOS/phylogenomics/python/subset_bam.py -i $samplefile -n 6 -p 4
while read line
do
arr=($line);
f=${arr[1]}
echo $f
done < $samplefile


# for f in LAB13_DNA942 NWL1105_DNA778 RNA9_DNA1188 DEN13_DNA793
# do
# $REPOS/phylogenomics/converting/bam_to_fasta.sh $f.small.bam $f

#### aTRAM libs
# perl $REPOS/aTRAM/format_sra.pl -in $f.fasta -out aTRAMdbs/$f -num 10

#### use CLC genomics workbench 7.0.3 to do de novo assembly of the reads
#### rename the outputted contigs to more sensible names.
# sed s/\.small\.bam_.no_read_group._.paired.// < $f.contigs.fa | sed s/Average\ coverage:.*$// > $f.contigs.fasta

#### use velvet
# velveth $f 31 -shortPaired -fasta -interleaved $f.fasta
# velvetg $f -cov_cutoff 20 -ins_length 400 -min_contig_lgth 300
# sed s/cov_\d+\.\d+// < $f/contigs.fa > $f.contigs.fasta
#### make draft plastome
# perl $REPOS/phylogenomics/plastome/contigs_to_cp.pl -ref $reffile -contig $f.contigs.fasta -out $f.plastome

#### clean draft plastome
# perl $REPOS/phylogenomics/plastome/clean_cp.pl -ref $reffile -contig $f.plastome.draft.fasta -out $f.plastome.clean.fasta

# done;
