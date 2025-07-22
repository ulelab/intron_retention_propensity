import re
import pandas as pd

# Input/output settings
input_path = "/scratch/prj/ppn_rnp_networks/users/mike.jones/data/splice/CrypticSS_All_Inferences.tsv"
output_path = "/scratch/prj/ppn_rnp_networks/users/mike.jones/data/splice/Splice_All.filtered.bed"
logfile = "/scratch/prj/ppn_rnp_networks/users/mike.jones/software/logs/header_parse_failures.log"

# Choose format: "matrix" (CrypticSS) or "fasta" (RBPNet)
input_format = "matrix"

log = open(logfile, "w")
bed_records = []

with open(input_path, "r") as infile:
    lines = infile.readlines()

    for idx, line in enumerate(lines):
        line = line.strip()
        if not line or (input_format == "fasta" and not line.startswith(">")):
            continue
        if input_format == "matrix" and (line.startswith("ID") or line.startswith("#")):
            continue

        if input_format == "fasta":
            header = line.strip()[1:]
            profile_target = lines[idx + 4].strip().split()
            match = re.match(r'^([^:]+)::([^:]+):(\d+)-(\d+)\(([+-])\)', header)
            if not match:
                log.write(f"Header parse error on line {idx+1}: {header}\n")
                continue
            gene, chrom, start, end, strand = match.groups()
            start, end = int(start), int(end)

            for j, score in enumerate(profile_target):
                try:
                    score = float(score)
                    if score < 1e-6:
                        continue
                    if strand == "+":
                        pos_start = start + j
                    else:
                        pos_start = end - (j + 1)
                    bed_records.append([chrom, pos_start, pos_start + 1, gene, f"{score:.6f}", strand])
                except:
                    log.write(f"Score parse error on line {idx+5}: {profile_target[j]}\n")
                    continue

        elif input_format == "matrix":
            fields = line.split("\t")
            intron_id = fields[0]
            prediction_blocks = fields[1:]
            try:
                gene, loc = intron_id.split("::")
                chrom_region, strand = loc.strip(")").split("(")
                chrom, coords = chrom_region.split(":")
                start_coord, end_coord = map(int, coords.split("-"))
            except Exception as e:
                log.write(f"Header parse error on line {idx+1}: {intron_id} ({e})\n")
                continue

            for pred in prediction_blocks:
                parts = pred.strip().split(",")
                if len(parts) != 3:
                    continue
                acceptor, donor, pos = parts
                try:
                    pos = int(pos)
                    donor = float(donor)
                    if donor < 1e-6:
                        continue
                    if strand == "+":
                        pos_start = start_coord + (pos - 1)
                    else:
                        pos_start = end_coord - pos
                    bed_records.append([chrom, pos_start, pos_start + 1, gene, f"{donor:.6f}", strand])
                except Exception as e:
                    log.write(f"Prediction parse error: {pred} for {intron_id} ({e})\n")

log.close()

# Output as BED file
df = pd.DataFrame(bed_records, columns=["chrom", "start", "end", "name", "score", "strand"])
df = df.sort_values(by=["chrom", "start", "end"])
df.to_csv(output_path, sep="\t", header=False, index=False)

print(f"✅ Strand-aware BED written: {output_path}")

