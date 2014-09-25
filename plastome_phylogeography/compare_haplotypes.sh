#!/bin/bash

#### $samplefile has a sample file with server, name, path
samplefile=$1

REFS=$2/*

CWD=$(pwd)

for ref in $REFS
do
	filename=$(basename "$ref")
	refname="${filename%.*}"
#
	bowtie2-build $ref $refname.index 2>/dev/null
	mkdir $refname
	cd $CWD/$refname
	pwd
	#### $samplefile has a sample file with server, name, path
	echo "" > samplefile.txt
	while read line
	do
		arr=($line);
		sample=${arr[1]}
		location=${arr[2]}
		echo $sample >> samplefile.txt

		if [ -f $sample.vcf ]
		then
			echo "$sample.vcf already exists"
		else
			if [ -f ${arr[2]} ];
			then
				echo "using $ref as reference"
				echo "processing $sample..."
#
    			echo "samtools view $location | head -n 2000000 | samtools view -S -u - > $sample.small.bam"
    			samtools view $location | head -n 2000000 | samtools view -S -u - > $sample.small.bam
#
        		$REPOS/phylogenomics/converting/bam_to_fastq.sh $sample.small.bam $sample
        		$REPOS/phylogenomics/converting/unpair_seqs.pl $sample.fastq $sample
        		bowtie2 -p 8 --no-unal --no-discordant --no-mixed --no-contain --no-unal -x ../$refname.index -1 $sample.1.fastq -2 $sample.2.fastq -S $sample.sam
				echo "samtools view -S -b -u $sample.sam | samtools view -F 4 -b - > $sample.reduced.bam"
		        samtools view -S -b -u $sample.sam | samtools view -F 4 -b - > $sample.reduced.bam
		        rm $sample.sam $sample.small.bam
				mv $sample.reduced.bam $sample.bam
				samtools sort $sample.bam $sample.sorted
				rm $sample.bam $sample.fastq $sample.*.fastq
				samtools mpileup -B -C50 -I -f $ref -u $sample.sorted.bam > $sample.bcf
				bcftools view -c $sample.bcf > $sample.vcf
				rm $sample.bcf $sample.sorted.bam
			fi
		fi
	done < $samplefile
	cd $CWD
done

for ref in $REFS
do
	filename=$(basename "$ref")
	refname="${filename%.*}"
	echo "$refname" > $refname.results.txt
	cd $CWD/$refname

	#for vcffile in $vcfs
	while read $sample
	do
		perl $REPOS/phylogenomics/analysis/count_SNPs.pl -sample $sample.vcf >> ../$refname.results.txt
	done < samplefile.txt
	cd $CWD
done
