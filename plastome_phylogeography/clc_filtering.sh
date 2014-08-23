#!/bin/bash

#### for each de novo sample:

# for f in LAB13_DNA942 NWL1105_DNA778 RNA9_DNA1188 DEN13_DNA793
# do
# python $REPOS/phylogenomics/python/subset_bam.py -i $SAMPLE -n 6 -p 4
#### use CLC genomics workbench 7.0.3 to do de novo assembly of the reads
# sed s/\.small\.bam_.no_read_group._.paired.// < $f.contigs.fa | sed s/Average\ coverage:.*$// > $f.contigs.fasta
# blastn -query $f.contigs.fasta -subject $POPULUS/reference_seqs/populus.trichocarpa.cp.fasta -outfmt '6 qseqid' | sort -u - > $f.cp.contigs.txt
# perl $REPOS/phylogenomics/filtering/select_seqs_from_fasta.pl $f.contigs.fasta $f.cp.contigs.txt
# done;
#
#### take this into zpicture and align against tricho reference to verify synteny

#### aTRAM libs
for f in LAB13_DNA942 NWL1105_DNA778 RNA9_DNA1188 DEN13_DNA793
do
bash $REPOS/phylogenomics/converting/bam_to_fasta.sh $f.small.bam $f
perl $REPOS/aTRAM/format_sra.pl -in $f.fasta -out $f -num 10

done;
