#!/bin/bash

# ===============================================
# Script: collapse_all_levels.sh
# Description: Collapse QIIME2 feature table to taxonomic levels 1–7
#              and generate absolute and relative tables for each level,
#              including TSV and BIOM exports.
# Usage:
#   bash collapse_all_levels.sh table.qza taxonomy.qza
# ===============================================

TABLE=$1
TAXONOMY=$2

# --- INPUT CHECKS ---
if [[ ! -f "$TABLE" ]] || [[ ! -f "$TAXONOMY" ]]; then
    echo " Error: Make sure '$TABLE' and '$TAXONOMY' exist in current directory."
    exit 1
fi

# --- OUTPUT DIRECTORIES ---
MAIN_DIR="collapsed_levels_results"
ABS_DIR="${MAIN_DIR}/absolute_tables"
REL_DIR="${MAIN_DIR}/relative_tables"
mkdir -p "$ABS_DIR" "$REL_DIR"

echo " Output directories created:"
echo "   - $ABS_DIR"
echo "   - $REL_DIR"
echo

# --- LOOP OVER TAXONOMIC LEVELS 1–7 ---
for LEVEL in {1..7}; do
    echo " Processing taxonomic level $LEVEL..."

    # Collapsed absolute table
    qiime taxa collapse \
        --i-table "$TABLE" \
        --i-taxonomy "$TAXONOMY" \
        --p-level $LEVEL \
        --o-collapsed-table "${ABS_DIR}/absolute_level${LEVEL}.qza"

    # Relative frequency table
    qiime feature-table relative-frequency \
        --i-table "${ABS_DIR}/absolute_level${LEVEL}.qza" \
        --o-relative-frequency-table "${REL_DIR}/relative_level${LEVEL}.qza"

    # Export absolute and relative tables to TSV and BIOM
    for TYPE in absolute relative; do
        DIR="${TYPE}_dir"
        if [[ "$TYPE" == "absolute" ]]; then
            DIR="$ABS_DIR"
        else
            DIR="$REL_DIR"
        fi

        QZA_PATH="${DIR}/${TYPE}_level${LEVEL}.qza"
        EXPORT_DIR="${DIR}/${TYPE}_export"
        mkdir -p "$EXPORT_DIR"

        qiime tools export \
            --input-path "$QZA_PATH" \
            --output-path "$EXPORT_DIR"

        biom convert \
            -i "${EXPORT_DIR}/feature-table.biom" \
            -o "${DIR}/${TYPE}_level${LEVEL}.tsv" \
            --to-tsv

        mv "${EXPORT_DIR}/feature-table.biom" "${DIR}/${TYPE}_level${LEVEL}.biom"
        rm -rf "$EXPORT_DIR"
    done

    echo " Level $LEVEL completed."
    echo
done

echo " All taxonomic levels processed successfully!"
echo " Final structure in '$MAIN_DIR':"
echo "   - absolute_tables/absolute_level*.qza/.tsv/.biom"
echo "   - relative_tables/relative_level*.qza/.tsv/.biom"

# --- OPTIONAL: Convert decimal points to commas for Excel ---
# Uncomment below if needed:
# for i in {1..7}; do
#     sed 's/\./,/g' "${ABS_DIR}/absolute_level${i}.tsv" > "${ABS_DIR}/abs_level${i}.tsv"
#     sed 's/\./,/g' "${REL_DIR}/relative_level${i}.tsv" > "${REL_DIR}/rel_level${i}.tsv"
# done
