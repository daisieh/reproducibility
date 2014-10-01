#!/bin/bash

#### Map populations

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

OUTNAME=$2;

#### perform downstream analyses:
#### generate a KML file for the populations:
gawk -F "\t" 'NR > 1 {print $5"\t"$6"\t"$11"\t"$10}' $INFILE | sort | uniq > $OUTNAME.locs.txt
perl $REPOS/phylogenomics/reporting/make_kml.pl -input $OUTNAME.locs.txt -c species_colors.txt -o $OUTNAME
