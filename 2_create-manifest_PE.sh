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
# Script: create-manifest_PE.sh
# Description: Generates a QIIME2-compliant Paired-End manifest file.
# Input 1: Metadata file (TSV/CSV) with sample IDs in the first column.
# Input 2: (optional) Directory containing FASTQ files.
# Output: manifest.txt
# =====================================================================

SAMPLE_METADATA=$1
READS_DIR=$2  # optional: can also be hardcoded below if needed

# If no directory is passed, EXIT with an error
if [[ -z "$SAMPLE_METADATA" || -z "$READS_DIR" ]]; then
    echo "Usage: $0 <sample_metadata.tsv> <reads_directory>"
    exit 1
fi

# Ensure absolute file path
READS_DIR=$(readlink -f "$READS_DIR")

# Manifest header (QIIME2 format: PairedEndFastqManifestPhred33V2)
echo -e "sample-id\tforward-absolute-filepath\treverse-absolute-filepath" > manifest.txt

# Loop through sample IDs (skip header)
tail -n +2 "$SAMPLE_METADATA" | cut -f1 | while read -r SAMPLE; do
    R1=$(find "$READS_DIR" -type f | grep "${SAMPLE}_" | grep "R1" | grep "\.fastq\.gz" | xargs realpath)
    R2=$(find "$READS_DIR" -type f | grep "${SAMPLE}_" | grep "R2" | grep "\.fastq\.gz" | xargs realpath)

    echo -e "${SAMPLE}\t${R1}\t${R2}" >> manifest.txt
done

echo "Manifest created successfully: manifest.txt"
