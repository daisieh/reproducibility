#!/bin/bash

# cluster directives
#PBS -l nodes=1:ppn=8
#PBS -l walltime=240:00:00
#PBS -l mem=8000mb
#PBS -j oe
#PBS -l epilogue=/home/daisieh/epilogue.script

OUTDIR=$1
REFDIR=$OUTDIR/pop_refs

if [ -n $REPOS ];
then
REPOS=$HOME;
fi


# The Populus trichocarpa reference annotation is available at: http://genome.jgi.doe.gov/pages/dynamicOrganismDownload.jsf?organism=Ptrichocarpa#
POTRI_GFF=Ptrichocarpa_210_gene_exons.gff3

# The Populus trichocarpa reference genome is available at: http://genome.jgi.doe.gov/pages/dynamicOrganismDownload.jsf?organism=Ptrichocarpa#
POTRI_FASTA=Ptrichocarpa_210.fasta
salix_bam=/data/raid50/GalaxyData/Populus/PopulusTrichocarpa/DNA/2012-08-17/IX0393/C10ERACXX_5/IX0393_C10ERACXX_5_ACAAAC.bam
SALIX="Sal_erio"

samtools view $salix_bam | gawk '{if (and($2,0x0200)) next; if (and($2,0x0040)) {print ">"$1"/1\n"$10; next;} if (and($2,0x0080)) {print ">"$1"/2\n"$10; next;} print ">"$1"\n"$10;}' - > $SALIX.genome.fasta

# prepare the aTRAM database
perl $REPOS/aTRAM/format_sra.pl -input $SALIX.genome.fasta -output $OUTDIR/$SALIX.db
rm $SALIX.genome.fasta

printf "$SALIX\t$OUTDIR/$SALIX.db.atram\n" > $OUTDIR/$SALIX.txt

grep "gene" $POTRI_GFF | gawk -F "\t" '{print $9;}' | head -n 5 | gawk -F ";Name=" '{print $2;}' > $OUTDIR/ref_genes.txt

# slice files for reference
perl $REPOS/phylogenomics/parsing/slice_gff_from_fasta.pl -gff $POTRI_GFF -fasta $POTRI_FASTA -out $REFDIR -gene $OUTDIR/ref_genes.txt

# now we have a directory, $REFDIR, filled with fasta references for all possible genes. We actually only want to work on the first isoform's first CDS, so find just those:

mkdir $REFDIR/cds
while read g
do
	perl $REPOS/phylogenomics/filtering/select_one_from_fasta.pl -fasta $REFDIR/$g.fasta -outputfile $REFDIR/cds/$g -seq $g.1.CDS.1
	printf "$g\t$REFDIR/cds/$g.fasta" >> $OUTDIR/genelist.txt
done < $OUTDIR/ref_genes.txt

# run aTRAM BasicPipeline on all genes
perl $REPOS/aTRAM/Pipelines/BasicPipeline.pl -samples $OUTDIR/$SALIX.txt -targets $OUTDIR/genelist.txt -out $OUTDIR -processes 8 -iter 5 -max_memory 8 -debug

mkdir $OUTDIR/$SALIX/best
mv $OUTDIR/$SALIX/*.best.fasta $OUTDIR/$SALIX/best/

# validate genes:
cat $REFDIR/cds/* > $REFDIR/cdslist.fasta
perl $REPOS/aTRAM/Postprocessing/ValidateGenes.pl -input $OUTDIR/best/ -reference $REFDIR/cdslist.fasta -output $OUTDIR/validate

# filter single genes.
perl $REPOS/phylogenomics/filtering/filter_atram_single_copy_only.pl -validate $OUTDIR/validate/results.txt -contig $OUTDIR/best -out $OUTDIR/single
# output is in $chr/single/genelist.txt

# blast list
perl $REPOS/phylogenomics/parsing/blast_list.pl -ref $REFDIR/cds -gene $OUTDIR/single/genelist.txt -fasta $OUTDIR/single/ -out $OUTDIR/blast

# filter list for best hits
cd $OUTDIR
perl $REPOS/phylogenomics/filtering/cdscutoff.pl single/genelist.txt blast/ 90
cd ..

# merge gff
perl $REPOS/phylogenomics/parsing/merge_to_gff.pl -gff $POTRI_GFF -gene $OUTDIR/cutoff.90 -fasta $OUTDIR/single/ -blast $OUTDIR/blast -out $OUTDIR/gff

# rename all to Ser.ph:
FILES=/home/daisieh/complete_chrs/gff/*
for file in $FILES
do
sed 's/Potri/Ser.ph.Potri/g' $file > Ser.ph.$file
rm -f $file
done

mv /home/daisieh/complete_chrs/gff/ /home/daisieh/complete_chrs/Ser_Potri_ph

# make list of these gff files:
ls -1 /home/daisieh/complete_chrs/Ser_Potri_ph > /home/daisieh/complete_chrs/gfflist.txt

# set up the pairwise comparison:
while read p
do
echo $p
perl $REPOS/phylogenomics/pipelines/pairwise_ser2pop_cds.pl -gff /home/daisieh/complete_chrs/Ser_Potri_ph/$p -ref $refdir -out /home/daisieh/complete_chrs/pairwise
done < /home/daisieh/complete_chrs/gfflist.txt

