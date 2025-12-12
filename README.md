# super-meta-phaseolus

16S rRNA Bioinformatics Pipeline (QIIME2-based)

This repository contains a reproducible and modular 16S rRNA processing pipeline built using QIIME2.
Only reusable scripts, parameter files, and example dummy inputs are provided.

-----------------------------------------------------------

##  Pipeline Overview

Import & Demultiplexing
Primer trimming (cutadapt)
Quality assessment
Denoising (DADA2)
ASV table generation
Taxonomic assignment
Taxonomic collapsing

Each step corresponds to a script in the scripts/ directory.
------------------------------------------------------------

##  Usage

Run each module independently:
```
bash scripts/1_get_and_train_silvaDB.sh
bash scripts/01_trim_cutadapt.sh
```

------------------------------------------------------------
Analysis Pipeline
------------------------------------------------------------
1. Demultiplexing: Raw paired-end Illumina reads were demultiplexed using QIIME2 v2025.4.

2. Primer Removal: Primer sequences were removed using the cutadapt trim-paired plugin.

3. Quality Assessment: Read quality was evaluated using qiime demux summarize to determine optimal trimming thresholds.

4. Denoising & Filtering: Forward and reverse reads were trimmed at Q20. DADA2 denoise-paired was used for filtering, denoising, merging, and chimera removal. This step produced:
    - Amplicon Sequence Variants (ASVs)
    - Representative sequences for each ASV.

5. Taxonomic Assignment: ASVs were classified using a Naïve Bayes classifier trained on SILVA 138.2 (99%), specific for the V3–V4 region of the 16S rRNA gene.

6. Taxonomic Collapsing: Absolute and relative abundance tables were collapsed across taxonomic levels (Domain → Genus) for downstream analyses.

7. Merge tables to Excel: csv format 

------------------------------------------------------------
Directory Structure
------------------------------------------------------------
Phseolus_vulgaris
script/
sample-metadata.tsv
silva_138.2_db_SSURef_NR99_dna_classifier.qza

------------------------------------------------------------
Notes
------------------------------------------------------------

The raw sequencing files are not included in this repository.

All analyses were conducted using QIIME2 v2025.4.

The pipeline can be adapted for other hypervariable regions or primer sets.

Sample-specific metadata were integrated from the first steps of the pipeline.

Final .tsv and .csv files include normalized abundances and collapsed taxonomic levels for each dataset.

.qzv visualization files can be viewed via QIIME2 View: https://view.qiime2.org
