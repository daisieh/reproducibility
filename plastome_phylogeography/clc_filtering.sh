#!/bin/bash

for f in LAB13_DNA942 NWL1105_DNA778 RNA9_DNA1188 DEN13_DNA793
do 
blastn -query $f.contigs.fa -subject Populus/reference_seqs/populus.trichocarpa.cp.fasta -outfmt '6 qseqid' | sort -u - > $f.cp.contigs.txt
perl ~/phylogenomics/filtering/select_seqs_from_fasta.pl $f.contigs.fa $f.cp.contigs.txt 
done;
