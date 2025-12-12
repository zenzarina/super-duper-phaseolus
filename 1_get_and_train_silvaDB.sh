#!/bin/bash

#
# Copyright 2021 Simone Maestri. All rights reserved.
# Simone Maestri <simone.maestri@univr.it>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

########################################
# VARIABLES
########################################

# PCR primers (V3–V4)
FW=AGCCTACGGGNGGCWGCAG ## insert your own!! 
RV=GACTACHVGGGTATCTAATCC

# Expected working directory: databases/silva
conda activate nano

########################################
# FUNCTION DEFINITIONS
########################################

# 1 — Download SILVA database for 16S
Download() {
    qiime rescript get-silva-data \
        --p-version '138.2' \
        --p-target 'SSURef_NR99' \
        --o-silva-sequences silva-138.2-ssu-nr99-rna-seqs.qza \
        --o-silva-taxonomy silva-138.2-ssu-nr99-tax.qza
}

# 2 — RNA → DNA conversion
Retro-transcr() {
    qiime rescript reverse-transcribe \
        --i-rna-sequences silva-138.2-ssu-nr99-rna-seqs.qza \
        --o-dna-sequences silva-138.2-ssu-nr99-seqs.qza
}

# 3 — Remove ambiguous bases / homopolymers
Culling() {
    qiime rescript cull-seqs \
        --i-sequences silva-138.2-ssu-nr99-seqs.qza \
        --o-clean-sequences silva-138.2-ssu-nr99-seqs-cleaned.qza
}

# 4 — Filter sequences by length and taxonomy
Filtering() {
    qiime rescript filter-seqs-length-by-taxon \
        --i-sequences silva-138.2-ssu-nr99-seqs-cleaned.qza \
        --i-taxonomy silva-138.2-ssu-nr99-tax.qza \
        --p-labels Archaea Bacteria Eukaryota \
        --p-min-lens 900 1200 1400 \
        --o-filtered-seqs silva-138.2-ssu-nr99-seqs-filt.qza \
        --o-discarded-seqs silva-138.2-ssu-nr99-seqs-discard.qza
}

# 5 — Dereplication (full-length)
Dereplicate-1() {
    qiime rescript dereplicate \
        --i-sequences silva-138.2-ssu-nr99-seqs-filt.qza \
        --i-taxa silva-138.2-ssu-nr99-tax.qza \
        --p-mode 'uniq' \
        --o-dereplicated-sequences silva-138.2-ssu-nr99-seqs-derep-uniq.qza \
        --o-dereplicated-taxa silva-138.2-ssu-nr99-tax-derep-uniq.qza
}

# 6 — Extract V3–V4 region in silico
Extract-region() {
    qiime feature-classifier extract-reads \
        --i-sequences silva-138.2-ssu-nr99-seqs-derep-uniq.qza \
        --p-f-primer $FW \
        --p-r-primer $RV \
        --p-min-length 100 \
        --p-max-length 600 \
        --p-n-jobs 2 \
        --p-read-orientation forward \
        --o-reads re-seqs-V3V4.qza
}

# 7 — Dereplication after region extraction
Dereplicate-2() {
    qiime rescript dereplicate \
        --i-sequences re-seqs-V3V4.qza \
        --i-taxa silva-138.2-ssu-nr99-tax-derep-uniq.qza \
        --p-mode uniq \
        --o-dereplicated-sequences silva-138.2-ref-seqs-V3V4-uniq.qza \
        --o-dereplicated-taxa silva-138.2-ref-seqs-V3V4-derep-uniq.qza
}

# 8 — Train Naïve Bayes classifier
Train() {
    qiime feature-classifier fit-classifier-naive-bayes \
        --i-reference-reads silva-138.2-ref-seqs-V3V4-uniq.qza \
        --i-reference-taxonomy silva-138.2-ref-seqs-V3V4-derep-uniq.qza \
        --o-classifier silva_138.2_db_SSURef_NR99_dna_classifier.qza
}

########################################
# MAIN
########################################

Download
Retro-transcr
Culling
Filtering
Dereplicate-1
Extract-region
Dereplicate-2
Train

########################################
# NOTES
########################################

# If the SILVA database is already downloaded and only needs
# amplicon extraction + classifier training,
# you can start directly from: Extract-region
