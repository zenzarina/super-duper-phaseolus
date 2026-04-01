#!/usr/bin/env python3

"""
merge_to_excel.py
Merge QIIME2 collapsed TSV tables (absolute and relative) into a single Excel file.

- Automatic detection of all TSVs in collapsed_levels_results
- Cleans headers (#OTU ID -> Taxon)
- Creates one sheet per level for absolute and relative tables
- Keeps clean formatting (no extra columns/rows)

Usage:
    python merge_to_excel.py
"""

import pandas as pd
from pathlib import Path

# Base directory
BASE_DIR = Path("collapsed_levels_results")
OUTPUT_EXCEL = BASE_DIR / "all_levels_tables.xlsx"

with pd.ExcelWriter(OUTPUT_EXCEL, engine="openpyxl") as writer:
    for mode in ["absolute_tables", "relative_tables"]:
        mode_dir = BASE_DIR / mode

        # loop over levels
        for level_dir in sorted(mode_dir.glob("level*")):
            level = level_dir.name  # es. level1

            # find TSVs
            tsv_files = list(level_dir.glob("*.tsv"))
            if not tsv_files:
                continue

            # take the first TSV
            tsv_path = tsv_files[0]
            df = pd.read_csv(tsv_path, sep="\t", comment="#")

            # clean header
            if "#OTU ID" in df.columns:
                df = df.rename(columns={"#OTU ID": "Taxon"})
            elif "OTU ID" in df.columns:
                df = df.rename(columns={"OTU ID": "Taxon"})

            # set Taxon as index
            df = df.set_index("Taxon")

            # Sheet name e.g., "Abs_L1" o "Rel_L1"
            sheet_name = f"{'Abs' if 'absolute' in mode else 'Rel'}_{level[-1]}"

            # write to Excel
            df.to_excel(writer, sheet_name=sheet_name)

            print(f"✅ Added {sheet_name} from {tsv_path}")

print(f"\n🎉 Excel successfully created: {OUTPUT_EXCEL}")
