#!/bin/bash

#### $samplefile has a sample file with name, path to reads in fasta format.
samplefile=$1

#### for each de novo sample:
reffile="$REPOS/reproducibility/plastome_assembly/balsamifera_cp.gb"
if [ -e $2 ];
then
	reffile=$2
fi
echo "using $reffile as reference"

perl $REPOS/phylogenomics/parsing/genbank.pl $reffile

CWD=$(pwd)
while read line
do
	arr=($line);
	sample=${arr[0]};
	comment=$(echo $line | grep -c "#" -)
	if [ $comment -ne 0 ];
	then
		echo "skipping $sample"
		continue;
	fi
	echo "processing $sample..."
	mkdir $sample
	cd $sample
	perl $REPOS/phylogenomics/parsing/plann.pl -sample $sample -ref ../$reffile -fasta $sample.plastome.draft.fasta -out $sample.tbl


# • You need to make a template file in Sequin. Open Sequin, go to "Create a new submission," and fill out the first panel's tabs about Submission/Contact/Authors/Affiliation, then on the last tab (Affiliation), you click the "Click here to export a template" and save that file somewhere. This can be used for all of your Sequin submissions. Alternatively, go to http://www.ncbi.nlm.nih.gov/WebSub/template.cgi and create a template there.

# If you put all of the paired .fsa/.tbl files in one directory, you can call tbl2asn with the -p flag and the path to that directory; the program will make a .sqn file for every .fsa file it finds.
#
# Then you run tbl2asn -t [template file] -p [fsa directory], and you'll get all the corresponding .sqn files. In Sequin, you can open them with "Read existing record" and check to make sure there are no errors, then remake the sequin file and you're ready to submit to Genbank!



	cd $CWD
done < $samplefile
