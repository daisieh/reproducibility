#!/bin/bash

#### $samplefile has a sample file with server, name, path
CWD=$(pwd)

cd $(dirname "$1")
samplefile=$(pwd)/$(basename "$1")
cd $CWD

cd $(dirname "$2")
REFS=$(pwd)/$(basename "$2")/*.fasta
cd $CWD

while read line
do
	arr=($line);
	sample=${arr[1]}
	location=${arr[2]}
	if [ -f ${arr[2]} ];
	then
		samtools view -f 12 -F 256 $location | head -n 4000000 | samtools view -S -u - > $sample.small.bam

		$REPOS/phylogenomics/converting/bam_to_fastq.sh $sample.small.bam $sample
		$REPOS/phylogenomics/converting/unpair_seqs.pl $sample.fastq $sample
		for ref in $REFS
		do
			filename=$(basename "$ref")
			refname="${filename%.*}"
		#
			if [ -f $refname.index.1.bt2 ]
			then
				echo "using $refname as index"
			else
				bowtie2-build $ref $refname.index 2>/dev/null
			fi
			mkdir $refname
			cd $CWD/$refname
			pwd


			if [ -f $sample.vcf ]
			then
				echo "$sample.vcf already exists"
			else
					echo "using $ref as reference"
					echo "processing $sample..."

					bowtie2 -p 8 --no-unal --no-discordant --no-mixed --no-contain --no-unal -x ../$refname.index -1 ../$sample.1.fastq -2 ../$sample.2.fastq -S $sample.sam
					echo "samtools view -S -b -u $sample.sam | samtools view -F 4 -b - > $sample.reduced.bam"
					samtools view -S -b -u $sample.sam | samtools view -F 4 -b - > $sample.reduced.bam
					rm $sample.sam
					mv $sample.reduced.bam $sample.bam
					samtools sort $sample.bam $sample.sorted
					rm $sample.bam
					samtools mpileup -B -C50 -I -f $ref -u $sample.sorted.bam > $sample.bcf
					bcftools view -c $sample.bcf > $sample.vcf
					rm $sample.bcf $sample.sorted.bam
				fi
			cd $CWD
		done
		rm $sample.small.bam $sample.fastq $sample.*.fastq
	fi
done < $samplefile

rm $2/*.fai
$REPOS/reproducibility/plastome_phylogeography/count_snps.sh $1 $2
$REPOS/phylogenomics/converting/combine_files.pl -input results/* -head -names > results.txt
