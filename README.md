# super-duper-phaseolus

16S rRNA Bioinformatics Pipeline (QIIME2-based)

This repository contains a reproducible and modular 16S rRNA processing pipeline built using QIIME2.
Only reusable scripts, parameter files, and example dummy inputs are provided.

-----------------------------------------------------------

## 🧪 Pipeline Overview

Import & Demultiplexing
Primer trimming (cutadapt)
Quality assessment
Denoising (DADA2)
ASV table generation
Taxonomic assignment
Taxonomic collapsing
Basic visualizations

Each step corresponds to a script in the scripts/ directory.
------------------------------------------------------------

## 🛠️ Usage

Run each module independently:
```
bash scripts/00_import.sh
bash scripts/01_trim_cutadapt.sh
bash scripts/02_dada2.sh
```
Or integrate them into your own pipeline/workflow.

------------------------------------------------------------
## 🎯 Notes

This repository contains no raw FASTQ files, sample identifiers, or sensitive metadata.
The pipeline can be adapted for other hypervariable regions or primer sets.

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

8. Taxonomic Collapsing: Absolute and relative abundance tables were collapsed across taxonomic levels (Domain → Genus) for downstream analyses.

9. Merge tables to Excel: csv format 

------------------------------------------------------------
Directory Structure
------------------------------------------------------------
Phseolus_vulgaris
script/
sample-metadata.tsv
silva_138.2_db_SSURef_NR99_dna_classifier.qza


The main directory follows this internal organization:
1_trimming_cutadapt/ – Primer-free reads
2_dada2_output/ – ASV tables and representative sequences
3_taxonomy_assignment/ – Taxonomic assignments (SILVA 138.2)
4_collapsed_levels/ – Abundance tables for each taxonomic level
5_visualizations/ – Quality plots and QIIME2 visualizations
sample-metadata.tsv – Subsample metadata
manifest.txt – Manifest file for QIIME2 data import

+ script/
+   ├─ 1_get_and_train_silvaDB.sh
+   ├─ 2_create_manifest_PE.sh
+   ├─ 3_import_data.sh
+   ├─ 4_denoise_sequences.sh
+   ├─ 8_collapse_all_levels.sh
+   └─ 9_merge_to_excel.py
+ collapsed_levels_results/
+   ├─ absolute_tables/
+   └─ relative_tables/
+ sample-metadata.tsv
+ silva_138.2_db_SSURef_NR99_dna_classifier.qza

------------------------------------------------------------
Notes
------------------------------------------------------------

The raw sequencing files are not included in this repository.

All analyses were conducted using QIIME2 v2025.4.

Sample-specific metadata were integrated from the first steps of the pipeline.

Table structure is consistent across both datasets (Andes and Meso), enabling direct comparison of intermediate and final results.

Final .tsv and .csv files include normalized abundances and collapsed taxonomic levels for each dataset.

.qzv visualization files can be viewed via QIIME2 View: https://view.qiime2.org
