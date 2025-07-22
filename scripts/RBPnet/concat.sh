#!/bin/bash

OUTPUT_DIR="/scratch/prj/ppn_rnp_networks/users/mike.jones/software/RBPnet/pred"
COMBINED="$OUTPUT_DIR/pred.tsv"

# Create or empty the output file
> "$COMBINED"

# Loop over files in correct order
for i in $(seq -w 0 63); do
    FILE="$OUTPUT_DIR/batch_${i}.tsv"
    if [ -s "$FILE" ]; then
        cat "$FILE" >> "$COMBINED"
    else
        echo "Warning: $FILE is empty or missing"
    fi
done

echo "Combined file written to $COMBINED"

