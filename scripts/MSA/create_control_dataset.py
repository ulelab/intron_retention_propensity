#!/usr/bin/env python3
"""
Create a control dataset by sampling from canonical and non-PRPF8 splice sites.
Samples 5000 rows from each file, combines, removes duplicates, and expands coordinates.
"""

import pandas as pd
import numpy as np
import argparse
import sys

def expand_coordinates(df, expand_bp=24):
    """
    Expand BED coordinates by expand_bp on each side.
    Ensures start doesn't go below 0.
    """
    df_expanded = df.copy()
    df_expanded['start'] = (df_expanded['start'] - expand_bp).clip(lower=0)
    df_expanded['end'] = df_expanded['end'] + expand_bp
    return df_expanded

def main():
    parser = argparse.ArgumentParser(
        description='Create control dataset from canonical and non-PRPF8 splice sites'
    )
    parser.add_argument('--canonical', required=True,
                       help='Path to Canonical_splice_sites.bed')
    parser.add_argument('--nonprpf8', required=True,
                       help='Path to NonPRPF8SpliceSites_f250.bed')
    parser.add_argument('--output', required=True,
                       help='Output BED file path')
    parser.add_argument('--n_samples', type=int, default=5000,
                       help='Number of samples to take from each file (default: 5000)')
    parser.add_argument('--expand', type=int, default=24,
                       help='Base pairs to expand on each side (default: 24)')
    parser.add_argument('--seed', type=int, default=42,
                       help='Random seed for reproducibility (default: 42)')
    
    args = parser.parse_args()
    
    # Set random seed
    np.random.seed(args.seed)
    
    print("=" * 60)
    print("Creating Control Dataset")
    print("=" * 60)
    print(f"Canonical file: {args.canonical}")
    print(f"Non-PRPF8 file: {args.nonprpf8}")
    print(f"Samples per file: {args.n_samples}")
    print(f"Total expected: {args.n_samples * 2}")
    print(f"Coordinate expansion: ±{args.expand} bp")
    print("=" * 60)
    print()
    
    # Read canonical splice sites
    print(f"Reading {args.canonical}...")
    try:
        canonical = pd.read_csv(args.canonical, sep='\t', header=None,
                               names=['chr', 'start', 'end', 'name', 'score', 'strand'],
                               usecols=[0, 1, 2, 3, 4, 5])
    except Exception as e:
        print(f"ERROR reading canonical file: {e}", file=sys.stderr)
        sys.exit(1)
    
    print(f"  Loaded {len(canonical)} rows")
    
    # Read non-PRPF8 splice sites
    print(f"Reading {args.nonprpf8}...")
    try:
        nonprpf8 = pd.read_csv(args.nonprpf8, sep='\t', header=None,
                              names=['chr', 'start', 'end', 'name', 'score', 'strand'],
                              usecols=[0, 1, 2, 3, 4, 5])
    except Exception as e:
        print(f"ERROR reading non-PRPF8 file: {e}", file=sys.stderr)
        sys.exit(1)
    
    print(f"  Loaded {len(nonprpf8)} rows")
    
    # Filter non-PRPF8 sites: column 5 (score) must be > 0.0002
    print(f"Filtering non-PRPF8 sites: score > 0.0002...")
    nonprpf8_filtered = nonprpf8[nonprpf8['score'] > 0.0002].copy()
    print(f"  After filtering: {len(nonprpf8_filtered)} rows (removed {len(nonprpf8) - len(nonprpf8_filtered)})")
    nonprpf8 = nonprpf8_filtered
    print()
    
    # Sample from each file
    print(f"Sampling {args.n_samples} rows from canonical...")
    if len(canonical) < args.n_samples:
        print(f"  WARNING: Only {len(canonical)} rows available, using all")
        canonical_sample = canonical.copy()
    else:
        canonical_sample = canonical.sample(n=args.n_samples, random_state=args.seed)
    
    print(f"Sampling {args.n_samples} rows from non-PRPF8...")
    if len(nonprpf8) < args.n_samples:
        print(f"  WARNING: Only {len(nonprpf8)} rows available, using all")
        nonprpf8_sample = nonprpf8.sample(n=args.n_samples, random_state=args.seed + 1)
    else:
        nonprpf8_sample = nonprpf8.sample(n=args.n_samples, random_state=args.seed + 1)
    
    print()
    
    # Combine samples
    print("Combining samples...")
    combined = pd.concat([canonical_sample, nonprpf8_sample], ignore_index=True)
    print(f"  Combined total: {len(combined)} rows")
    print()
    
    # Check for duplicates (by chr, start, end, strand)
    print("Checking for duplicates...")
    duplicate_key = ['chr', 'start', 'end', 'strand']
    duplicates = combined.duplicated(subset=duplicate_key, keep=False)
    n_duplicates = duplicates.sum()
    
    if n_duplicates > 0:
        print(f"  Found {n_duplicates} duplicate rows (same chr, start, end, strand)")
        print("  Removing duplicates (keeping first occurrence)...")
        combined = combined.drop_duplicates(subset=duplicate_key, keep='first')
        print(f"  After deduplication: {len(combined)} rows")
    else:
        print("  No duplicates found")
    print()
    
    # Expand coordinates
    print(f"Expanding coordinates by ±{args.expand} bp...")
    combined_expanded = expand_coordinates(combined, expand_bp=args.expand)
    
    # Show some statistics
    print()
    print("Coordinate expansion summary:")
    original_widths = combined['end'] - combined['start']
    expanded_widths = combined_expanded['end'] - combined_expanded['start']
    print(f"  Original width range: {original_widths.min()} - {original_widths.max()} bp")
    print(f"  Expanded width range: {expanded_widths.min()} - {expanded_widths.max()} bp")
    print(f"  Mean expansion: {(expanded_widths - original_widths).mean():.1f} bp")
    print()
    
    # Sort by chromosome and start position
    print("Sorting by chromosome and start position...")
    combined_expanded = combined_expanded.sort_values(['chr', 'start', 'end'])
    print()
    
    # Write output
    print(f"Writing output to {args.output}...")
    combined_expanded.to_csv(args.output, sep='\t', header=False, index=False)
    print(f"  Written {len(combined_expanded)} rows")
    print()
    
    # Summary
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"Canonical samples: {len(canonical_sample)}")
    print(f"Non-PRPF8 samples: {len(nonprpf8_sample)}")
    print(f"Combined (before dedup): {len(canonical_sample) + len(nonprpf8_sample)}")
    print(f"Final (after dedup): {len(combined_expanded)}")
    print(f"Duplicates removed: {len(canonical_sample) + len(nonprpf8_sample) - len(combined_expanded)}")
    print(f"Output file: {args.output}")
    print("=" * 60)

if __name__ == '__main__':
    main()

