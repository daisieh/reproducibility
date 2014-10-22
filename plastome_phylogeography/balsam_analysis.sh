#!/bin/bash

#### Performs phylogeographic analysis of POPCAN's P. balsamifera samples (or others).

if [ -z $REPOS ];
then
REPOS=$HOME;
fi

#### a file with the list of samples:
####1file_id	2sample	3DNA_code	4ADM_#	5species	6POP_CODE	7POPNAME	8POP#	9GROUP	10LONG	11LAT	12server	13path	14plastome

INFILE=$1;
if [ ! -f $1 ];
then
echo "no samplefile specified"
INFILE=balsam_sample_data.txt
fi

REFGB=$2;
if [ ! -f $2 ];
then
echo "no reference specified"
REFGB=trichocarpa_cp.gb
fi

subsample="-n 0"
if [ $3 ];
then
echo "subsample"
subsample="-n 10000000"
fi

#### make fasta file from ref gb

refname=$(echo "$(cd "$(dirname "$REFGB")" && pwd)/$(basename "$REFGB" .gb)")
# refname=$(basename "$REFGB" .gb);
REF=$refname.fasta
perl $REPOS/phylogenomics/converting/gb_to_fasta.pl -in $REFGB -out $REF
echo "reference is now $REF"
CURRDIR=$PWD
filename=$(basename "$INFILE" .txt);

RESULTDIR=$filename
OUTNAME=$RESULTDIR/$filename

mkdir $RESULTDIR
#### check to remove any files to paths that don't exist on this machine.
bash $REPOS/reproducibility/plastome_phylogeography/process_sample_data.sh $INFILE > $OUTNAME.1.txt

cd $RESULTDIR
#### run the bam to vcf pipeline:

echo "python $REPOS/phylogenomics/python/bwa_to_bam.py -i ../$OUTNAME.1.txt -r $REF -p 8 $subsample"
python $REPOS/phylogenomics/python/bwa_to_bam.py -i ../$OUTNAME.1.txt -r $REF -p 8 $subsample
python $REPOS/phylogenomics/python/bam_to_vcf.py -i ../$OUTNAME.1.txt -r $REF -p 8

#### convert the vcfs to fasta:
gawk '{print $2".vcf"}' ../$OUTNAME.1.txt > ../$OUTNAME.2.txt
perl $REPOS/phylogenomics/converting/vcf_to_fasta.pl -samples ../$OUTNAME.2.txt -output ../$OUTNAME -thresh 0 -cov 300
cd $CURRDIR

#### perform downstream analyses:

#### trim strict to define backbone haplotype groups
# perl $REPOS/phylogenomics/parsing/trim_missing.pl -fasta $OUTNAME.fasta -out $OUTNAME_strict -row 0.05 -col 0.05
# perl $REPOS/phylogenomics/converting/convert_file.pl $OUTNAME_strict.fasta $OUTNAME_strict.nex
# sed s/OUTNAME/$OUTNAME/ <paup.txt >$OUTNAME_paup.txt
# cat $OUTNAME_strict.nex $OUTNAME_paup.txt > $OUTNAME_backbone.nex
# paup $OUTNAME_backbone.nex
#### get support values for the backbone branches

#### look into how PASTA divides an unrooted tree into subgraphs

#### mapping populations:
#### map with hap A in red / everything else in white
#### possibly pies for haplotypes.
#
#### #convert to nexus:
# perl $REPOS/phylogenomics/converting/convert_file.pl $OUTNAME.locs.fasta $OUTNAME.locs.nex

#### trim missing data at the 0.1 missing threshold:
# perl $REPOS/phylogenomics/parsing/trim_missing.pl -in $OUTNAME.fasta -out $OUTNAME.trimmed.fasta -row 0.7 -col 0.1
# assign all individuals with a more relaxed trimming to assign to hap groups
# investigate possible patterns for identical haplotypes: within populations? How frequent?
# use hap groups to inform sampling strategy for de novo assembly

#### need to do a couple more de novo plastomes for the hap B
#### filter all balsam reads against the 5 balsam haplotype reference sequences: if the number of SNPs is never below a similarity threshold (prob ~20 SNPS) to any of the haplotypes, then it is probably not a balsam plastome.
