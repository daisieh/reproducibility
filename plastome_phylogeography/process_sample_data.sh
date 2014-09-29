#!/usr/bin/bash

#### check to remove any files to paths that don't exist on this machine.
samplefile="samplefile.txt"

rm $samplefile

#### balsam_sample_data.txt is a file with the list of samples:
####1file_id	2sample	3DNA_code	4ADM_#	5species	6POP_CODE	7POPNAME	8POP#	9GROUP	10LONG	11LAT	12server	13path	14plastome

gawk '$0 !~ /^#/' $1 | gawk -F " " '{print $11"\t"$1"\t"$12}' |
{
while read line
do
	arr=($line);
	if [ -f ${arr[2]} ];
	then
	echo $line
	echo $line >> $samplefile;
	fi
done;
};

