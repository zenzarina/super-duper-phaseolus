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
# Script: import_data.sh
# Description: Import paired-end FASTQ files into QIIME2, summarize
#              quality, remove primers, and re-summarize.
# Usage:
#   bash import_data.sh manifest.txt FW_PRIMER RV_PRIMER
# Example:
#   nohup bash import_data.sh manifest.txt AGCCTACGGGNGGCWGCAG GACTACHVGGGTATCTAATCC &
# =====================================================================

MANIFEST=$1
FW_PRIMER=$2
RV_PRIMER=$3

# --- BASIC CHECKS -----------------------------------------------------

if [[ -z "$MANIFEST" || -z "$FW_PRIMER" || -z "$RV_PRIMER" ]]; then
    echo "Usage: $0 <manifest.txt> <FW_PRIMER> <RV_PRIMER>"
    exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
    echo "ERROR: Manifest file not found: $MANIFEST"
    exit 1
fi

echo " Importing paired-end data using manifest: $MANIFEST"
echo " Forward primer: $FW_PRIMER"
echo " Reverse primer: $RV_PRIMER"

# --- STEP 1: IMPORT SEQUENCES -----------------------------------------

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path "$MANIFEST" \
    --output-path sequences_untrimmed.qza \
    --input-format PairedEndFastqManifestPhred33V2

# --- STEP 2: QUALITY SUMMARY (RAW) ------------------------------------

qiime demux summarize \
    --i-data sequences_untrimmed.qza \
    --o-visualization demux_summary_untrimmed.qzv \
    --verbose

# --- STEP 3: PRIMER REMOVAL (CUTADAPT) -------------------------------

qiime cutadapt trim-paired \
    --i-demultiplexed-sequences sequences_untrimmed.qza \
    --p-front-f "$FW_PRIMER" \
    --p-front-r "$RV_PRIMER" \
    --p-discard-untrimmed \
    --p-cores 40 \
    --o-trimmed-sequences sequences.qza \
    --verbose

# --- STEP 4: QUALITY SUMMARY (TRIMMED) -------------------------------

qiime demux summarize \
    --i-data sequences.qza \
    --o-visualization demux_summary_trimmed.qzv \
    --verbose

echo " Import completed. Generated:"
echo "   - sequences_untrimmed.qza"
echo "   - demux_summary_untrimmed.qzv"
echo "   - sequences.qza"
echo "   - demux_summary_trimmed.qzv"
