#!/bin/bash

for file in ERR345*.fastq.gz; do
    echo "Processing $file"
    python removespace.py "$file"
done