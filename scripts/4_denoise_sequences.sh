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

# =====================================================================
# Script: denoise_sequences.sh
# Description: Paired-end denoising with DADA2. Produces ASV table,
#              representative sequences, quality summaries and stats.
# Usage:
#   bash denoise_sequences.sh TRIM_F TRIM_R TRUNC_F TRUNC_R
# Example:
#   nohup bash denoise_sequences.sh 0 0 276 206 &
# =====================================================================

TRIM_LEFT_F=$1
TRIM_LEFT_R=$2
TRUNC_LEN_F=$3
TRUNC_LEN_R=$4

# --- BASIC CHECKS -----------------------------------------------------

if [[ -z "$TRIM_LEFT_F" || -z "$TRIM_LEFT_R" || -z "$TRUNC_LEN_F" || -z "$TRUNC_LEN_R" ]]; then
    echo "Usage: $0 <trim-left-f> <trim-left-r> <trunc-len-f> <trunc-len-r>"
    exit 1
fi

if [[ ! -f "sequences.qza" ]]; then
    echo "ERROR: sequences.qza not found. Run import_data.sh first."
    exit 1
fi

if [[ ! -f "sample-metadata.tsv" ]]; then
    echo "ERROR: sample-metadata.tsv not found. Required for summaries."
    exit 1
fi

echo " Running DADA2 denoising with parameters:"
echo "   trim-left-f   = $TRIM_LEFT_F"
echo "   trim-left-r   = $TRIM_LEFT_R"
echo "   trunc-len-f   = $TRUNC_LEN_F"
echo "   trunc-len-r   = $TRUNC_LEN_R"

# --- STEP 1: DENOISING WITH DADA2 -------------------------------------

qiime dada2 denoise-paired \
    --i-demultiplexed-seqs sequences.qza \
    --p-trim-left-f "$TRIM_LEFT_F" \
    --p-trim-left-r "$TRIM_LEFT_R" \
    --p-trunc-len-f "$TRUNC_LEN_F" \
    --p-trunc-len-r "$TRUNC_LEN_R" \
    --p-n-threads 50 \
    --o-table table.qza \
    --o-representative-sequences rep-seqs.qza \
    --o-denoising-stats denoising-stats.qza \
    --verbose

# --- STEP 2: SUMMARIZE FEATURE TABLE ---------------------------------

qiime feature-table summarize \
    --i-table table.qza \
    --o-visualization table.qzv \
    --m-sample-metadata-file sample-metadata.tsv

# --- STEP 3: SUMMARIZE REPRESENTATIVE SEQUENCES -----------------------

qiime feature-table tabulate-seqs \
    --i-data rep-seqs.qza \
    --o-visualization rep-seqs.qzv

# --- STEP 4: EXTENDED SUMMARY (PLUS) ----------------------------------

qiime feature-table summarize-plus \
    --i-table table.qza \
    --m-sample-metadata-file sample-metadata.tsv \
    --o-feature-frequencies feature-frequencies.qza \
    --o-sample-frequencies sample-frequencies.qza \
    --o-summary summary.qzv

# --- STEP 5: DENOISING STATS TABLE -----------------------------------

qiime metadata tabulate \
    --m-input-file denoising-stats.qza \
    --o-visualization denoising-stats.qzv

echo " Denoising completed. Generated:"
echo "   - table.qza / table.qzv"
echo "   - rep-seqs.qza / rep-seqs.qzv"
echo "   - feature-frequencies.qza"
echo "   - sample-frequencies.qza"
echo "   - summary.qzv"
echo "   - denoising-stats.qza / denoising-stats.qzv"
