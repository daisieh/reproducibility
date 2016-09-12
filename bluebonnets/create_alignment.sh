#!/bin/bash

cd /Volumes/Pantry2

# -I skips indels
# -A includes anomalous reads (GBS is all anomalous reads)
# -B Disable probabilistic realignment for the computation of base alignment quality (BAQ).
samtools mpileup -I -A -B -f reference.fasta -uv cp/*.sorted.bam > cp/chloroplast.vcf
$REPOS/phylogenomics/converting/vcf_to_fasta.pl -input cp/chloroplast.vcf -multiple -min 1000 -out cp/chloroplast
$REPOS/phylogenomics/parsing/trim_missing.pl -input cp/chloroplast.fasta -out cp/trimmed_cp.fasta -row 0.1

# 
# while read line
# do
# arr=($line);
# samplename=${arr[2]};
# echo $samplename
# 
# # samples/concat_samples/$samplename.1.fq
# samtools mpileup -I -A -B -f reference.fasta -uv cp/$samplename.sorted.bam > cp/$samplename.vcf
# 
# 
# done < /Volumes/Pantry2/all_barcodes.txt
