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
REFS=$2/*

for ref in $REFS
do
	filename=$(basename "$ref")
	refname="${filename%.*}"

	bowtie2-build $ref $refname.index 2>/dev/null
	mkdir $refname
	cd $refname
	pwd
	#### $samplefile has a sample file with server, name, path
	while read line
	do
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
				echo "using $ref as reference"
				echo "processing $sample..."

    			echo "samtools view $location | head -n 2000000 | samtools view -S -u - > $sample.small.bam"
    			samtools view $location | head -n 2000000 | samtools view -S -u - > $sample.small.bam

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
	done < ../$samplefile
	cd ..
done
