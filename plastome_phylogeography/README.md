Methods
=======
Note: `$PHYLOGENOMICS` refers to [this repository](https://github.com/daisieh/phylogenomics).

Sampling
========
The master sample list used for this paper is [all_samples.txt](https://github.com/daisieh/reproducibility/blob/plastome-phylogeography/plastome_phylogeography/all_samples.txt). This file contains the names used to refer to the samples throughout, as well as their provenances, species IDs, and paths on the POPCAN servers.

Overview phylogeny
==================
A subset of samples, representing the within-species diversity as well as the relative phylogenetic position of the plastomes of the species, was piled up against the Salix interior plastome (Genbank [KJ742926](http://www.ncbi.nlm.nih.gov/nuccore/KJ742926)) using the `pileup_analysis.sh` script:

  ```bash pileup_analysis.sh overview_samples.txt salix_cp.gb subsample```

The script was run on both servers (east and west) and then the resulting fasta files were merged as `overview_samples.fasta`.

The fasta file was trimmed for missing data:

  ```perl $PHYLOGENOMICS/parsing/trim_missing.pl -fasta overview_samples.fasta -out overview_strict -row 0.9 -col 0.05```

Then RAxML was performed on the trimmed file, using the GTR+gamma model, with 100 bootstrapped replicates:

  ```perl $PHYLOGENOMICS/parsing/raxml.pl -in overview_strict.fasta -out overview_strict.nex```

