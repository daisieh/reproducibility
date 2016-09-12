#!/bin/bash

cd /Volumes/Pantry2/
mkdir samples/concat_samples

while read line
do
arr=($line);
samplename=${arr[2]};
echo $samplename

gzip -dc samples/lane6/$samplename.1.fq.gz > samples/concat_samples/$samplename.1.fq
gzip -dc samples/lane7/$samplename.1.fq.gz >> samples/concat_samples/$samplename.1.fq
gzip samples/concat_samples/$samplename.1.fq
rm samples/concat_samples/$samplename.1.fq

gzip -dc samples/lane6/$samplename.2.fq.gz > samples/concat_samples/$samplename.2.fq
gzip -dc samples/lane7/$samplename.2.fq.gz >> samples/concat_samples/$samplename.2.fq
gzip samples/concat_samples/$samplename.2.fq
rm samples/concat_samples/$samplename.1.fq

done < /Volumes/Pantry2/all_barcodes.txt
