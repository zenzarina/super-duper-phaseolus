#!/bin/bash

# Modify of Copyright 2021 Simone Maestri. All rights reserved.
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
# Script: 2_create-manifest_PE.sh
# Description: Generates a QIIME2-compliant Paired-End manifest file.
# Input 1: Metadata file (TSV/CSV) with sample IDs in the first column.
# Input 2: Directory containing FASTQ files.
# Output: manifest.txt
# Usage: 2_create-manifest_PE.sh <sample_metadata> <reads_dir>
# =====================================================================

SAMPLE_METADATA=$1
READS_DIR=$2  # #directory with files (optional: can also be hardcoded below if needed)

# If no directory is passed, EXIT with an error
if [[ -z "$SAMPLE_METADATA" || -z "$READS_DIR" ]]; then
    echo "Usage: $0 <sample_metadata.tsv> <reads_directory>"
    exit 1
fi

# Ensure absolute file path
READS_DIR=$(readlink -f "$READS_DIR")

#creating a manifest.txt with three columns
# sample ID | R1 forward absolute filepath | R2 reverse absolute filepath
# Manifest header (QIIME2 format: PairedEndFastqManifestPhred33V2)
echo -e sample-id"\t"forward-absolute-filepath"\t"reverse-absolute-filepath > manifest.txt

# Loop through sample IDs (skip header)
for s in $(cat $SAMPLE_METADATA | cut -f1 | tail -n +2); do
  echo $s;
  R1=$(realpath $(find $READS_DIR | grep $s"_" | grep "R1" | grep "\\.fastq\\.gz"));
  R2=$(realpath $(find $READS_DIR | grep $s"_" | grep "R2" | grep "\\.fastq\\.gz"));
  echo -e $s"\t"$R1"\t"$R2 >> manifest.txt
done

echo "Manifest created successfully: manifest.txt"
