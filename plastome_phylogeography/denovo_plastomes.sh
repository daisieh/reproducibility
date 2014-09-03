#!/bin/bash

#### for each de novo sample:
reffile="trichocarpa_cp.gb"

#### check to remove any files to paths that don't exist on this machine.
rm samplefile.txt
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
# echo "processing $sample..."
# echo "  making fasta from bam"
# $REPOS/phylogenomics/converting/bam_to_fasta.sh $sample.small.bam $sample
#
# #### aTRAM libs
# echo "  making aTRAM db"
# perl $REPOS/aTRAM/format_sra.pl -in $sample.fasta -out aTRAMdbs/$sample -num 10
# echo "$sample\t$aTRAMdbs/$sample.atram\n" >> atram_samples.txt
#
# #### use CLC genomics workbench 7.0.3 to do de novo assembly of the reads
# #### rename the outputted contigs to more sensible names.
# # sed s/\.small\.bam_.no_read_group._.paired.// < $sample.contigs.fa | sed s/Average\ coverage:.*$// > $sample.contigs.fasta
#
# #### use velvet
# echo "  assembling contigs with Velvet"
# velveth $sample 31 -shortPaired -fasta -interleaved $sample.fasta
# velvetg $sample -cov_cutoff 20 -ins_length 400 -min_contig_lgth 300
#
# #### rename contigs from NODE_2_length_25848_cov_191.293564 to $sample_
# sed s/NODE/$sample/ < $sample/contigs.fa | sed s/_length.*// > $sample.contigs.fasta
#
# #### make draft plastome
# echo "  assembling draft plastome from contigs"
# perl $REPOS/phylogenomics/plastome/contigs_to_cp.pl -ref $reffile -contig $sample.contigs.fasta -out $sample.plastome
#
# #### clean draft plastome
# perl $REPOS/phylogenomics/plastome/clean_cp.pl -ref $reffile -contig $sample.plastome.draft.fasta -out $sample.plastome
# done < $samplefile
#
# echo "Finished initial assembly"
# #### further cleanup steps
#
# while read line
# do
# arr=($line);
# sample=${arr[1]}
# echo "filling in $sample..."

#### find sections of ambiguity in the cleaned plastome:
grep -o -E ".{100}[Nn]+.{100}" $sample.plastome.cleaned.fasta > $sample.to_atram.txt

rm $sample.targets.txt
count=1
while read seq
do
echo ">$sample.$count" > $sample.$count.fasta
echo ">$seq" >> $sample.$count.fasta
echo "$sample.$count#$sample.$count.fasta" >> $sample.targets1.txt
count=$(($count+1))
done < $sample.to_atram.txt
echo "$sample#$aTRAMdbs/$sample.atram" > $sample.samples1.txt
sed "s/#/\t/g" < $sample.targets1.txt > $sample.targets.txt
sed "s/#/\t/g" < $sample.samples1.txt > $sample.samples.txt
rm $sample.targets1.txt
rm $sample.samples1.txt

#### aTRAM those ambiguous sections
echo "  aTRAM ambiguous sections"
perl $REPOS/aTRAM/Pipelines/BasicPipeline.pl -samples $sample.samples.txt -target $sample.targets.txt -frac 0.3 -iter 5 -out $sample.atram

#### Now, take the best seq from each one and align it to the draft:
cat $sample.plastome.cleaned.fasta > $sample.plastome.toaln.fasta
for ((i=1;i<=$count;i++))
do
head -n 2 $sample.atram/$sample.$i.best.fasta >> $sample.plastome.toaln.fasta
done

#### align these with mafft

mafft --auto $sample.plastome.toaln.fasta > $sample.plastome.aln.fasta

#### consolidate into consensus sequence
perl $REPOS/phylogenomics/filtering/consensus.pl $sample.plastome.aln.fasta > $sample.plastome.final.fasta

done < $samplefile
