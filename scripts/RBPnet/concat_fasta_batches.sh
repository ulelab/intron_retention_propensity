#!/bin/bash

INTRON_LIST="/scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/introns.tsv"
CHUNK_DIR="/scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/introns/concat_batches"
CHUNK_SIZE=3050
mkdir -p "$CHUNK_DIR"

counter=0
batch=0
output_file=""

while read -r fa; do
    if (( counter % CHUNK_SIZE == 0 )); then
        output_file=$(printf "%s/batch_%02d.fa" "$CHUNK_DIR" "$batch")
        echo "Creating $output_file"
        ((batch++))
    fi
    cat "$fa" >> "$output_file"
    ((counter++))
done < "$INTRON_LIST"

echo "Done. Total introns: $counter"
echo "Created $batch batch FASTA files in $CHUNK_DIR"
