Methods
=======
Note: `$PHYLOGENOMICS` refers to [this repository](https://github.com/daisieh/phylogenomics). `$REPOS` refers to the root path where Github repos are stored.

Sampling
========
The master sample list used for this paper is [all_samples.txt](https://github.com/daisieh/reproducibility/blob/plastome-phylogeography/plastome_phylogeography/all_samples.txt). This file contains the names used to refer to the samples throughout, as well as their provenances, species IDs, and paths on the POPCAN servers. Sequencing was performed as paired-end 100bp reads on an Illumina HiSeq.

Overview phylogeny
==================
A subset of samples, representing the within-species diversity as well as the relative phylogenetic position of the plastomes of the species, was piled up against the _Salix interior_ plastome (Genbank [KJ742926](http://www.ncbi.nlm.nih.gov/nuccore/KJ742926)) using the `pileup_analysis.sh` script:

  ```
  bash $REPOS/reproducibility/plastome_phylogeography/pileup_analysis.sh $REPOS/reproducibility/plastome_phylogeography/overview_samples.txt $REPOS/reproducibility/plastome_phylogeography/salix_cp.gb subsample
  ```

The script was run on both servers (east and west) and then the resulting fasta files were merged as `overview_samples.fasta`.

The fasta file was trimmed for missing data:

  ```
  perl $PHYLOGENOMICS/parsing/trim_missing.pl -fasta overview_samples.fasta -out overview_strict -row 0.9 -col 0.05
  ```

Then RAxML was performed on the trimmed file, using the GTR+gamma model, with 100 bootstrapped replicates:

  ```
  perl $PHYLOGENOMICS/parsing/raxml.pl -in overview_strict.fasta -out overview_strict.nex
  ```

Species assignment
==================
An individual from each major clade in the overview phylogeny was selected for denovo plastome assembly:

  ```
  bash ~/reproducibility/plastome_phylogeography/denovo_plastomes.sh ~/reproducibility/plastome_phylogeography/denovo_samples.txt ~/reproducibility/plastome_phylogeography/trichocarpa_cp.gb
  ```

These denovo assemblies were then used as comparisons for each individual: each sample was piled up against each denovo sequence and the snps were counted. The denovo sequence that had the smallest sequence divergence from the sample was chosen as the closest species/plastotype representative.


Haplotype assignment
====================
Based on the overview phylogeny, the overview samples were assigned to haplotype groups based on the major bifurcations in the tree. Group PG (Prince George) represents a unique plastotype distinct from both _P. trichocarpa_ and _P. balsamifera_. Both _P. trichocarpa_ and _P. balsamifera_ were divided into three haplotypes: in both species, the third haplotype is the one found in most individuals. Haplotypes were assigned by hand using FigTree for node selection.

Data aggregation
================
The combined datasets were aggregated by population:

  ```
  perl $REPOS/reproducibility/plastome_phylogeography/parse_haplotypes.pl $REPOS/reproducibility/plastome_phylogeography/all_samples.txt $REPOS/reproducibility/plastome_phylogeography/results/individual_haplotypes.txt > $REPOS/reproducibility/plastome_phylogeography/results/mapping/map_haps.txt
  ```

The resulting dataset was used in R to generate the aggregated maps:

  ```library(maps)
library(plotrix)
library(mapdata)
# overall map
dat <- read.table("~/Documents/Work/Sandbox/reproducibility/plastome_phylogeography/results/mapping/map_haps.txt", sep = "\t", header=TRUE, stringsAsFactors=FALSE)
map("worldHires","Canada",xlim=c(-155,-60),ylim=c(34,70),fill=TRUE,col="#FFFFFF",bg="#EEEEEE",interior=TRUE,resolution=0)
map("worldHires","USA",xlim=c(-155,-60),ylim=c(34,70),fill=TRUE,col="#FFFFFF",bg="#EEEEEE",interior=TRUE,resolution=0,add=TRUE)
map.axes()
for (x in 1:nrow(dat)) {  {floating.pie(dat$long[x],dat$lat[x],c(dat$T1[x],dat$T2[x],dat$T3[x],dat$PG[x],dat$B1[x],dat$B2[x],dat$B3[x]),radius=0.7,border=1,col=c("#DFDFFF","#7F7FFF","#0000FF","yellow","#FFC393","#FF9F52","#FF7300")) }}

# tricho inset
map("worldHires","Canada",xlim=c(-130,-120),ylim=c(44,55),fill=TRUE,col="#FFFFFF",bg="#EEEEEE",interior=TRUE,resolution=0)
map("worldHires","USA",xlim=c(-130,-120),ylim=c(44,55),fill=TRUE,col="#FFFFFF",bg="#EEEEEE",interior=TRUE,resolution=0,add=TRUE)
map.axes()
for (x in 1:nrow(dat)) {  {floating.pie(dat$long[x],dat$lat[x],c(dat$T1[x],dat$T2[x],dat$T3[x],dat$PG[x],dat$B1[x],dat$B2[x],dat$B3[x]),radius=0.2,border=1,col=c("#DFDFFF","#7F7FFF","#0000FF","yellow","#FFC393","#FF9F52","#FF7300")) }}
  ```
