#!/bin/bash
#SBATCH --cpus-per-task=8
#SBATCH --mem=12G

# Input files
fasta="/scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/sequences.fa"
pred="/scratch/prj/ppn_rnp_networks/users/mike.jones/software/rbpnet/pred/pred.tsv"
out="predstrand.tsv"
logfile="header_checkpoints.txt"

# Extract every other line starting from line 1 (FASTA headers)
awk 'NR % 2 == 1' "$fasta" > fasta_headers.tmp

# Clear previous log file
> "$logfile"

# Replace every 6th line in pred.tsv with lines from fasta_headers.tmp and log every 1000th
awk -v logfile="$logfile" '
    FNR==NR { hdr[NR]=$0; next }
    {
        if ((FNR-1) % 6 == 0) {
            old = $0
            new = hdr[++i]
            if (i % 1000 == 0) {
                print "Replacement " i ":"      >> logfile
                print "OLD: " old               >> logfile
                print "NEW: " new               >> logfile
                print ""                        >> logfile
            }
            print new
        } else {
            print
        }
    }
' fasta_headers.tmp "$pred" > "$out"

# Clean up
rm fasta_headers.tmp

echo "✅ Replaced prediction headers with FASTA headers in $out"
echo "📄 Logged every 1000th replacement to $logfile"

