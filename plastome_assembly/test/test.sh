#!/bin/bash

perl $REPOS/phylogenomics/plastome/plann.pl -ref $REPOS/reproducibility/plastome_assembly/balsamifera_cp.gb -fasta $REPOS/reproducibility/plastome_assembly/test/balsamifera_cp.fasta -out $REPOS/reproducibility/plastome_assembly/test/self_test_out -organism "Populus balsamifera" -sample "bals"

diff $REPOS/reproducibility/plastome_assembly/test/self_test_out.tbl $REPOS/reproducibility/plastome_assembly/test/self_test.tbl > $REPOS/reproducibility/plastome_assembly/test/self_test.diffs

if [ $? -eq 0 ]
then
  echo "Self-to-self test is fine."
else
  echo "Self-to-self test has diffs: " >&2
fi

perl $REPOS/phylogenomics/plastome/plann.pl -ref $REPOS/reproducibility/plastome_assembly/balsamifera_cp.gb -fasta $REPOS/reproducibility/plastome_assembly/test/populus.trichocarpa.cp.fasta -out $REPOS/reproducibility/plastome_assembly/test/tricho_test_out -organism "Populus trichocarpa" -sample "nisqually"

diff $REPOS/reproducibility/plastome_assembly/test/tricho_test_out.tbl $REPOS/reproducibility/plastome_assembly/test/tricho_test.tbl > $REPOS/reproducibility/plastome_assembly/test/tricho_test.diffs

if [ $? -eq 0 ]
then
  echo "Trichocarpa test is fine."
else
  echo "Trichocarpa test has diffs: " >&2
fi

perl $REPOS/phylogenomics/plastome/plann.pl -ref $REPOS/reproducibility/plastome_assembly/balsamifera_cp.gb -fasta $REPOS/reproducibility/plastome_assembly/test/jatropha_cp.fasta -out $REPOS/reproducibility/plastome_assembly/test/jatropha_test_out -organism "Jatropha curcas" -sample "jatropha"

#
# diff $REPOS/reproducibility/plastome_assembly/test/jatropha_test_out.tbl $REPOS/reproducibility/plastome_assembly/test/jatropha_test.tbl
#
# if [ $? -eq 0 ]
# then
#   echo "Plann self-test is fine."
# else
#   echo "Self-test file has diffs: " >&2
# fi
#

perl $REPOS/phylogenomics/plastome/plann.pl -ref $REPOS/reproducibility/plastome_assembly/balsamifera_cp.gb -fasta $REPOS/reproducibility/plastome_assembly/test/salix_cp.fasta -out $REPOS/reproducibility/plastome_assembly/test/salix_test_out -organism "Salix interior" -sample "salix"

#
# diff $REPOS/reproducibility/plastome_assembly/test/salix_test_out.tbl $REPOS/reproducibility/plastome_assembly/test/salix_test.tbl
#
# if [ $? -eq 0 ]
# then
#   echo "Plann self-test is fine."
# else
#   echo "Self-test file has diffs: " >&2
# fi
#

tbl2asn -p $REPOS/reproducibility/plastome_assembly/test/ -t $REPOS/reproducibility/plastome_assembly/test/plann.sbt
