#!/usr/bin/env python3

import os

# Settings
input_file = "/scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/rbpseqcln.fa"
output_dir = "split_batches"
batch_size = 6100

# Ensure output directory exists
os.makedirs(output_dir, exist_ok=True)

with open(input_file, "r") as f:
    lines = f.readlines()

for i in range(0, len(lines), batch_size):
    batch_lines = lines[i:i + batch_size]
    batch_index = i // batch_size
    batch_filename = os.path.join(output_dir, f"batch_{batch_index:02}.fa")
    with open(batch_filename, "w") as out:
        out.writelines(batch_lines)

print(f"Splitting complete. {batch_index + 1} batches written to {output_dir}")

