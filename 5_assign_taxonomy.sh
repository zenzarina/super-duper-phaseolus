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

# ===============================
# Input arguments
# ===============================
CLASSIFIER=$1          # pre-trained Naive Bayes classifier (.qza)
REP_SEQS=${2:-rep-seqs.qza}   # representative sequences
FEATURE_TABLE=${3:-table.qza} # feature table
METADATA=${4:-sample-metadata.tsv} # metadata file

# Output directories
BARPLOT_DIR="Bar_plot"
SPECIES_DIR="Collapsed_species"

mkdir -p "$BARPLOT_DIR" "$SPECIES_DIR"

# ===============================
# 1️⃣ Assign taxonomy using pre-trained classifier
# ===============================
qiime feature-classifier classify-sklearn \
  --i-classifier "$CLASSIFIER" \
  --i-reads "$REP_SEQS" \
  --p-n-jobs 1 \
  --o-classification taxonomy.qza

qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv

# ===============================
# 2️⃣ Create taxa bar plots
# ===============================
qiime taxa barplot \
  --i-table "$FEATURE_TABLE" \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file "$METADATA" \
  --o-visualization "$BARPLOT_DIR/taxa-bar-plots.qzv"

qiime tools export --input-path "$BARPLOT_DIR/taxa-bar-plots.qzv" --output-path "$BARPLOT_DIR"
mv "$BARPLOT_DIR/index.html" "$BARPLOT_DIR/bar_plot.html"

# ===============================
# 3️⃣ Collapse feature table to species level
# ===============================
qiime taxa collapse \
  --i-table "$FEATURE_TABLE" \
  --i-taxonomy taxonomy.qza \
  --p-level 7 \
  --o-collapsed-table "$SPECIES_DIR/table_collapsed_species.qza"

# Absolute frequencies
qiime tools export \
  --input-path "$SPECIES_DIR/table_collapsed_species.qza" \
  --output-path "$SPECIES_DIR"

mv "$SPECIES_DIR/feature-table.biom" "$SPECIES_DIR/feature-table_absfreq_species.biom"

biom convert \
  -i "$SPECIES_DIR/feature-table_absfreq_species.biom" \
  -o "$SPECIES_DIR/feature-table_absfreq_species.tsv" \
  --to-tsv --table-type 'Taxon table'

# Clean taxonomy labels for Excel
sed 's/[a-z]__//g' "$SPECIES_DIR/feature-table_absfreq_species.tsv" | tr '\t' ';' > "$SPECIES_DIR/feature-table_absfreq_species_ok.tsv"
sed -i '3 i Domain;Phylum;Class;Order;Family;Genus;Species' "$SPECIES_DIR/feature-table_absfreq_species_ok.tsv"

# Relative frequencies
qiime feature-table relative-frequency \
  --i-table "$SPECIES_DIR/table_collapsed_species.qza" \
  --o-relative-frequency-table "$SPECIES_DIR/table_collapsed_relfreq_species.qza"

qiime metadata tabulate \
  --m-input-file "$SPECIES_DIR/table_collapsed_relfreq_species.qza" \
  --o-visualization "$SPECIES_DIR/table_collapsed_relfreq_species.qzv"

qiime tools export \
  --input-path "$SPECIES_DIR/table_collapsed_relfreq_species.qza" \
  --output-path "$SPECIES_DIR"

mv "$SPECIES_DIR/feature-table.biom" "$SPECIES_DIR/feature-table_relfreq_species.biom"

biom convert \
  -i "$SPECIES_DIR/feature-table_relfreq_species.biom" \
  -o "$SPECIES_DIR/feature-table_relfreq_species.tsv" \
  --to-tsv --table-type 'Taxon table'

echo " Taxonomy assignment and species-level tables completed."
