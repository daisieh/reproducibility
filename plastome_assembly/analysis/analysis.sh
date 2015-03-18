#!/bin/bash

SAMPLES=*.gb

# extract the fasta sequences:
for GB in $SAMPLES
do
	echo "making $GB.fasta"
	perl $REPOS/phylogenomics/converting/gb_to_fasta.pl -input $GB
done;

for GB in $SAMPLES
do
	for FASTA in $SAMPLES
	do
		echo "comparing $FASTA.fasta to $GB"
		perl $REPOS/phylogenomics/plastome/plann.pl -ref $GB -fasta $FASTA.fasta -out $GB.$FASTA -organism "Populus balsamifera" -sample "bals"
	done;
done;

head -n 2 *.results.txt > all_results.txt

echo "Running tbl2asn"
tbl2asn -Vbv -p . -t plann.sbt
