#!/bin/bash

#### check to remove any files to paths that don't exist on this machine.
samplefile=samplefile.txt

# rm $samplefile
# gawk '$0 !~ /^#/' $1 |
# {
# while read line
# do
# arr=($line);
# if [ -f ${arr[2]} ];
# then
# echo $line
# echo $line >> $samplefile;
# fi
# done;
# };

gawk -F " " '{print $11"\t"$1"\t"$12}' $1 > $samplefile


for ref in $2/DEN13_HapC.fasta #$2/*
do
	filename=$(basename "$ref")
	refname="${filename%.*}"

	bowtie2-build $refname $refname.index
	mkdir $refname
	#### $samplefile has a sample file with server, name, path
	while read line
	do
		cd $refname
		echo "using $ref as reference"
		arr=($line);
		sample=${arr[1]}
		location=${arr[2]}
		echo ${arr[2]}
		if [ -f $sample.vcf ]
		then
			echo "$sample.vcf already exists"
		else
			if [ -f ${arr[2]} ];
			then
				echo "processing $sample..."

# 				python $REPOS/phylogenomics/python/bowtie_align.py -i ../$samplefile -r $ref -p 8 -n 2000000
#     			samtools view $location | head -n 2000000 | samtools view -S -u > $sample.small.bam
#
#         		$REPOS/phylogenomics/converting/bam_to_fastq.sh $sample.small.bam $sample
#         		$REPOS/phylogenomics/converting/unpair_seqs.pl $sample.fastq $sample
#         		bowtie2 -p 8 --no-unal --no-discordant --no-mixed --no-contain --no-unal -x ../$refname.index -1 $sample.1.fastq -2 $sample.2.fastq -S $sample.sam
# 		        samtools view -S -b -u $sample.sam | samtools view -F 4 -b - > $sample.reduced.bam
# 		        rm $sample.sam
# 				mv $sample.reduced.bam $sample.bam
# 				samtools sort $sample.bam $sample.sorted
				rm $sample.bam $sample.fastq $sample.*.fastq
				samtools mpileup -B -C50 -I -f $ref -u $sample.sorted.bam > $sample.bcf
				bcftools view -c $sample.bcf > $sample.vcf
				rm $sample.bcf $sample.sorted.bam $sample.small.bam
			fi
		fi
		cd ..
	done < $samplefile
done
