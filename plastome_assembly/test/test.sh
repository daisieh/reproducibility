#!/bin/bash

perl $REPOS/phylogenomics/plastome/plann.pl -ref $REPOS/reproducibility/plastome_assembly/balsamifera_cp.gb -fasta $REPOS/reproducibility/plastome_assembly/test/balsamifera_cp.fasta -out $REPOS/reproducibility/plastome_assembly/test/self_test_out -organism "Populus balsamifera" -sample "bals"

perl $REPOS/phylogenomics/plastome/plann.pl -ref $REPOS/reproducibility/plastome_assembly/balsamifera_cp.gb -fasta $REPOS/reproducibility/plastome_assembly/test/populus.trichocarpa.cp.fasta -out $REPOS/reproducibility/plastome_assembly/test/tricho_test_out -organism "Populus trichocarpa" -sample "nisqually"

perl $REPOS/phylogenomics/plastome/plann.pl -ref $REPOS/reproducibility/plastome_assembly/balsamifera_cp.gb -fasta $REPOS/reproducibility/plastome_assembly/test/salix_cp.fasta -out $REPOS/reproducibility/plastome_assembly/test/salix_test_out -organism "Salix interior" -sample "salix"

perl $REPOS/phylogenomics/plastome/plann.pl -ref $REPOS/reproducibility/plastome_assembly/balsamifera_cp.gb -fasta $REPOS/reproducibility/plastome_assembly/test/jatropha_cp.fasta -out $REPOS/reproducibility/plastome_assembly/test/jatropha_test_out -organism "Jatropha curcas" -sample "jatropha"


echo "Running tbl2asn"
tbl2asn -Vbv -p $REPOS/reproducibility/plastome_assembly/test/ -t $REPOS/reproducibility/plastome_assembly/test/plann.sbt
