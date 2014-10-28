#!/usr/bin/bash

#### check to remove any files to paths that don't exist on this machine.

#### all_sample_data.txt is a file with the list of samples:
####1file_id	2sample	3DNA_code	4species	5pop_code	6pop_name	7LONG	8LAT	9server	10path

#### remove commented lines:
gawk '$0 !~ /^#/' $1 |

# #### then print server, fileid, path
# gawk -F "\t" '{print $9"\t"$1"\t"$10}' |

#### then print only lines that have paths that exist
{
while read line
do
	arr=($line);
	file=${arr[9]};
	if [ -f $file ];
	then
		test={samtools view $file | head -n 1 | grep "Chr01"}
		echo $test
	echo -e "$line"
	fi
done;
};

