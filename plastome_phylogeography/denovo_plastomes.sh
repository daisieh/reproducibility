#!/bin/bash

#### for each de novo sample:
reffile="trichocarpa_cp.gb"

#### check to remove any files to paths that don't exist on this machine.
while read line
do
arr=($line);
if [ -f ${arr[2]} ];
then
echo $line >> samplefile.txt;
fi
done < $1

samplefile="samplefile.txt"

#### Take raw files and subset part for analysis:
# python $REPOS/phylogenomics/python/subset_bam.py -i $samplefile -n 6 -p 4

#### $samplefile has a sample file with server, name, path
while read line
do
arr=($line);
sample=${arr[1]}
echo "processing $sample..."

# $REPOS/phylogenomics/converting/bam_to_fasta.sh $sample.small.bam $sample

#### aTRAM libs
# perl $REPOS/aTRAM/format_sra.pl -in $sample.fasta -out aTRAMdbs/$sample -num 10

#### use CLC genomics workbench 7.0.3 to do de novo assembly of the reads
#### rename the outputted contigs to more sensible names.
# sed s/\.small\.bam_.no_read_group._.paired.// < $sample.contigs.fa | sed s/Average\ coverage:.*$// > $sample.contigs.fasta

#### use velvet
# velveth $sample 31 -shortPaired -fasta -interleaved $sample.fasta
# velvetg $sample -cov_cutoff 20 -ins_length 400 -min_contig_lgth 300
# sed s/cov_\d+\.\d+// < $sample/contigs.fa > $sample.contigs.fasta
#### make draft plastome
# perl $REPOS/phylogenomics/plastome/contigs_to_cp.pl -ref $reffile -contig $sample.contigs.fasta -out $sample.plastome

#### clean draft plastome
# perl $REPOS/phylogenomics/plastome/clean_cp.pl -ref $reffile -contig $sample.plastome.draft.fasta -out $sample.plastome

done < $samplefile
