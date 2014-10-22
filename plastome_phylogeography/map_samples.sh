#!/bin/bash

#### balsam_sample_data.txt is a file with the list of samples:

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

OUTNAME=$(basename "$INFILE" .txt);

####1file_id	2sample	3DNA_code	4ADM_#	5species	6POP_CODE	7POPNAME	8POP#	9GROUP	10LONG	11LAT	12server	13path	14plastome
####output is server, sample, path
gawk '$0 !~ /^#/' $INFILE | gawk -F "\t" '{print $2"\t"$3"\t"$10"\t"$11}' > $OUTNAME.all.txt

gawk -F "\t" '{print $6"\t"$10"\t"$11}' $INFILE | sort | uniq > $OUTNAME.pops.txt
