import argparse
import pandas as pd
import matplotlib.pyplot as plt
import qiime2
import gzip
import os
import sys
import re

def count_fastq_reads(fastq_path):
    """Counts sequences in a .fastq.gz file (Lines / 4)."""
    count = 0
    with gzip.open(fastq_path, 'rb') as f:
        for i, _ in enumerate(f):
            pass
    return (i + 1) // 4

def main():
    parser = argparse.ArgumentParser(description='Plot read distribution for Tables or Sequence artifacts.')
    parser.add_argument('--input', '-i', required=True, help='Path to .qza file')
    parser.add_argument('--output', '-o', default='distribution.png', help='Output image name')
    parser.add_argument('--title', '-t', default='Read Distribution', help='Plot title')
    args = parser.parse_args()

    print(f"Loading artifact: {args.input}...")
    artifact = qiime2.Artifact.load(args.input)
    semantic_type = str(artifact.type)
    
    counts = {}

    # MODE 1: It's a Feature Table (ASVs/Denoised)
    if 'FeatureTable[Frequency]' in semantic_type:
        print("Detected Feature Table. Summing frequencies...")
        df = artifact.view(pd.DataFrame)
        counts = df.sum(axis=1).to_dict()

    # MODE 2: It's Raw or Trimmed Sequences
    elif 'SampleData[PairedEndSequencesWithQuality]' in semantic_type or \
         'SampleData[SequencesWithQuality]' in semantic_type:
        print("Detected Sequence Data. Counting reads in FASTQs (this may take a minute)...")
        # We export to a temp directory to access FASTQs
        import tempfile
        with tempfile.TemporaryDirectory() as temp_dir:
            artifact.export_data(temp_dir)
            # Manifest tells us which file belongs to which sample
            manifest = pd.read_csv(os.path.join(temp_dir, 'MANIFEST'), index_col=0)
            for sample_id, row in manifest.iterrows():
                # We only need to count Forward reads (R1) to get the pair count
                fname = row['filename']
                if '_R1_' in fname or '_R1.' in fname:
                    fpath = os.path.join(temp_dir, fname)
                    counts[sample_id] = count_fastq_reads(fpath)
    else:
        print(f"Error: Unsupported type {semantic_type}")
        sys.exit(1)

    #------------- Sort by Reads Abundance  ------------- 
    # Convert to Series and sort (for reads abundances)
    #data = pd.Series(counts).sort_values(ascending=True)

    #------------- Sort by Sample ID ------------- 
      # Convert to Series
    data = pd.Series(counts)
    def extract_leading_number(sample_id):
        match = re.match(r'^(\d+)', str(sample_id))
        return int(match.group(1)) if match else float('inf')

    # Sort by that number
    data = data.sort_index(key=lambda x: x.map(extract_leading_number))
    #--------------------------------------------

    # Plotting
    plt.figure(figsize=(12, 6))
    plt.bar(range(len(data)), data.values, color='forestgreen', width=0.8)

    # Plotting by sample ID 
    plt.xticks(
        ticks=range(len(data)),
        labels=data.index,
        rotation=90,
        fontsize=6
    )

    plt.yscale('linear')
#    plt.xlabel(f"Samples (N={len(data)}) - Sorted by Abundance")
    plt.xlabel(f"Samples (N={len(data)}) - Sorted by Sample ID")
    plt.ylabel("Number of Reads (million)")
    plt.title(args.title)
    plt.grid(axis='y', linestyle='--', alpha=0.3)


# Calculate the mean
    mean_value = data.mean()
    plt.axhline(mean_value, color='red', linestyle='--', linewidth=2, label=f'Mean: {mean_value:.0f}')
    plt.legend()

    plt.savefig(args.output, dpi=300, bbox_inches='tight')
    print(f"Plot saved to {args.output}")

if __name__ == "__main__":
    main()
