#!/bin/bash

OUTPUT_DIR="/scratch/prj/ppn_rnp_networks/users/mike.jones/software/spliceAI/inf"
COMBINED="$OUTPUT_DIR/inf.tsv"

# Create or empty the output file
mkdir -p "$OUTPUT_DIR"
> "$COMBINED"

# Loop over files in correct order
for i in $(seq -w 0 63); do
    FILE="$OUTPUT_DIR/batch_${i}_triplets_noheader.tsv"
    if [ -s "$FILE" ]; then
        # Always ensure new line between files
        echo >> "$COMBINED"
        cat "$FILE" >> "$COMBINED"
    else
        echo "Warning: $FILE is empty or missing"
    fi
done

echo "✅ Combined file written to $COMBINED"

