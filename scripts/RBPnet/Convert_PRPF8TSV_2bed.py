import re
import sys
import pandas as pd

infile = "/scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/PRPF8_eCLIP_RBPbinding_Prediction.tsv"
bed_outfile = "/scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/PRPF8_eCLIP_RBPbinding_Prediction.filtered.bed"

logfile = "/scratch/prj/ppn_rnp_networks/users/mike.jones/software/rbpnet/logs/T2Bheader_parse_failures.log"
log = open(logfile, "w")

bed_records = []

with open(infile, 'r') as fin:
    lines = fin.readlines()

    for i in range(0, len(lines), 6):
        header = lines[i].strip()
        profile_target = lines[i+4].strip().split()

        match = re.match(r'^>([^:]+)::([^:]+):(\d+)-(\d+)\(([+-])\)', header)
        if not match:
            log.write(f"Header format error on line {i+1}: {header}\n")
            continue

        gene, chrom, start, end, strand = match.groups()
        start = int(start)
        end = int(end)

        for j, score in enumerate(profile_target):
            score = float(score)
            if score < 0.000001:
                continue  # filter low signal

            if strand == '+':
                pos_start = start + j
                pos_end = pos_start + 1
            else:
                pos_start = end - (j + 1)
                pos_end = pos_start + 1

            bed_records.append([f"chr{chrom}", pos_start, pos_end, gene, score, strand])

log.close()

# Convert to pandas for safe sorting and deduplication
bed_df = pd.DataFrame(bed_records, columns=["chrom", "start", "end", "name", "score", "strand"])

# Sort BED6
bed_df = bed_df.sort_values(by=["chrom", "start", "end", "strand"])

# Output filtered BED6 file
bed_df.to_csv(bed_outfile, sep='\t', header=False, index=False)

