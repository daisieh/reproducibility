#!/bin/bash

#### Performs phylogeographic analysis of POPCAN's P. balsamifera samples.

if [ -n $REPOS ];
then
REPOS=$HOME;
fi

#### a file with the list of samples:
####1file_id	2sample	3DNA_code	4ADM_#	5species	6POP_CODE	7POPNAME	8POP#	9GROUP	10LONG	11LAT	12server	13path	14plastome

INFILE=$1;
if [ -z $1 ];
then
INFILE=balsam_sample_data.txt
fi

REFGB=$2;
if [ -z $2 ];
then
REFGB=trichocarpa_cp.gb
fi

if [ $3 == "subsample" ];
then
subsample="-n 10000000"
fi

#### make fasta file from ref gb
refname=$(basename "$REFGB" .gb);
REF=$refname.fasta
perl $REPOS/phylogenomics/converting/gb_to_fasta.pl -in $REFGB -out $REF
echo "reference is now $REF"
CURRDIR=$PWD
filename=$(basename "$INFILE" .txt);

RESULTDIR=$filename
OUTNAME=$RESULTDIR/$filename

mkdir $RESULTDIR

#### check to remove any files to paths that don't exist on this machine.
bash $REPOS/reproducibility/plastome_phylogeography/process_sample_data.sh $1 > $OUTNAME.1.txt

INFILE=$OUTNAME.1.txt;

#### run the bam to vcf pipeline:

cd $RESULTDIR
# bash $REPOS/phylogenomics/pipelines/bam_to_plastome_vcf.sh ../$OUTNAME.1.txt
echo "python $REPOS/phylogenomics/python/bwa_to_bam.py -i ../$OUTNAME.1.txt -r $CURRDIR/$REF -p 8 $subsample"
python $REPOS/phylogenomics/python/bwa_to_bam.py -i ../$OUTNAME.1.txt -r $CURRDIR/$REF -p 8 $subsample
python $REPOS/phylogenomics/python/bam_to_vcf.py -i ../$OUTNAME.1.txt -r $CURRDIR/$REF -p 8

# while read line
# do
# 	arr=($line);
# 	sample=${arr[1]}
# 	$REPOS/phylogenomics/converting/bam_to_vcf.sh $sample $CURRDIR/$REF
# done < $CURRDIR/$OUTNAME.1.txt
#
cd $CURRDIR

#### convert the vcfs to fasta:
gawk -F "\t" 'NR > 1 {print $1".vcf"}' $INFILE > $OUTNAME.2.txt
perl $REPOS/phylogenomics/converting/vcf_to_fasta.pl -samples $OUTNAME.2.txt -output $OUTNAME -thresh 0 -cov 300


#### perform downstream analyses:
#### generate a KML file for the populations:
# gawk -F "\t" 'NR > 1 {print $5,$6,$11,$10}' $INFILE | sort | uniq > $OUTNAME.locs.txt
# perl $REPOS/phylogenomics/reporting/make_kml.pl -i $OUTNAME.locs.txt -c species_colors.txt -o $OUTNAME
#
#### rename samples by locality:
#### create a locality mapping:
# gawk -F "\t" 'NR > 1 {print $1,$2,$10}' $INFILE | gawk '{if ($3 < -110) {print $1,"W_"$2;next;}; if ($3 < -79) {print $1,"C_"$2;next;}; if ($3 < -50) {print $1,"E_"$2;next;}}' > $OUTNAME.rename.locs
# perl $REPOS/phylogenomics/converting/relabel_samples.pl -i $OUTNAME.trimmed.fasta -label $OUTNAME.rename.locs -out $OUTNAME.locs.fasta


#### trim strict to define backbone haplotype groups
# perl $REPOS/phylogenomics/parsing/trim_missing.pl -fasta $OUTNAME.fasta -out $OUTNAME_strict -row 0.05 -col 0.05
perl $REPOS/phylogenomics/converting/convert_file.pl $OUTNAME_strict.fasta $OUTNAME_strict.nex
sed s/OUTNAME/$OUTNAME/ <paup.txt >$OUTNAME_paup.txt
cat $OUTNAME_strict.nex $OUTNAME_paup.txt > $OUTNAME_backbone.nex
paup $OUTNAME_backbone.nex
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
