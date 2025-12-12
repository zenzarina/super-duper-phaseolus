# super-duper-phaseolus

16S rRNA Analysis – Andes & Meso Groups

This repository contains all bioinformatic analyses performed on the 16S rRNA samples belonging to the Andes and Meso groups.
Both groups were processed independently but following the same pipeline, parameters, and quality thresholds.

------------------------------------------------------------
Analysis Pipeline
------------------------------------------------------------
1. Demultiplexing: Raw paired-end Illumina reads were demultiplexed using QIIME2 v2025.4.

2. Primer Removal: Primer sequences were removed using the cutadapt trim-paired plugin.

3. Quality Assessment: Read quality was evaluated using qiime demux summarize to determine optimal trimming thresholds.

4. Denoising & Filtering: Forward and reverse reads were trimmed to 280 bp and 270 bp respectively (Q20). DADA2 denoise-paired was used for filtering, denoising, merging, and chimera removal. This step produced:
    - Amplicon Sequence Variants (ASVs)
    - Representative sequences for each ASV.

5. Taxonomic Assignment: ASVs were classified using a Naïve Bayes classifier trained on SILVA 138.2 (99%), specific for the V3–V4 region of the 16S rRNA gene.

6. Taxonomic Collapsing: Absolute and relative abundance tables were collapsed across taxonomic levels (Domain → Genus) for downstream analyses.

------------------------------------------------------------
Directory Structure
------------------------------------------------------------
ande/
meso/
script/
sample-metadata.tsv
silva_138.2_db_SSURef_NR99_dna_classifier.qza


Each group directory (Andes, Meso) follows the same internal organization:
1_trimming_cutadapt/ – Primer-free reads
2_dada2_output/ – ASV tables and representative sequences
3_taxonomy_assignment/ – Taxonomic assignments (SILVA 138.2)
4_collapsed_levels/ – Abundance tables for each taxonomic level
5_visualizations/ – Quality plots and QIIME2 visualizations
sample-metadata.tsv – Subsample metadata
manifest.txt – Manifest file for QIIME2 data import

------------------------------------------------------------
Notes
------------------------------------------------------------

The raw sequencing files are not included in this repository.

All analyses were conducted using QIIME2 v2025.4.

Sample-specific metadata were integrated from the first steps of the pipeline.

Table structure is consistent across both datasets (Andes and Meso), enabling direct comparison of intermediate and final results.

Final .tsv and .csv files include normalized abundances and collapsed taxonomic levels for each dataset.

.qzv visualization files can be viewed via QIIME2 View: https://view.qiime2.org
