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
bash scripts/2_Create_manifest_PE.sh
```

------------------------------------------------------------
Analysis Pipeline
------------------------------------------------------------
1. Database & Classifier – SILVA 138.2 V3–V4 sequences, dereplicated, filtered, and trained as a Naïve Bayes classifier.

2. Demultiplexing – Raw paired-end reads → sequences_untrimmed.qza.

3. Primer Removal – Remove primers with cutadapt trim-paired → sequences.qza. Quality Assessment – Visualize read quality with qiime demux summarize.

4. Denoising & Filtering – DADA2 to produce ASVs (rep-seqs.qza), feature table (table.qza), and stats.

5. Taxonomic Assignment – Classify ASVs with trained SILVA classifier → taxonomy.qza, taxonomy.qzv, barplots.

6. Collapsing – Feature tables collapsed across taxonomic levels (Domain → Species) → absolute & relative tables (.qza, .biom, .tsv).

7. Merge to Excel – All levels combined in a single Excel workbook, one sheet per level, absolute & relative abundances.

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
