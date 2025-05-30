#!/bin/bash

# Extract paths from dataspec.yml
FASTA=$(grep "^fasta_file:" dataspec.yml | awk '{print $2}')
POS_BW=$(grep -A2 "main:" dataspec.yml | grep ".pos.bw" | tr -d "- ")
NEG_BW=$(grep -A2 "main:" dataspec.yml | grep ".neg.bw" | tr -d "- ")
BED=$(grep "peaks:" dataspec.yml | awk '{print $2}')

echo "FASTA: $FASTA"
echo "Positive BW: $POS_BW"
echo "Negative BW: $NEG_BW"
echo "BED: $BED"

# 1. Check BigWig chromosome sizes match
echo -e "\nComparing chromosome coverage in bigwigs:"
bigWigInfo -chroms $POS_BW | sort > pos.chroms.txt
bigWigInfo -chroms $NEG_BW | sort > neg.chroms.txt
diff pos.chroms.txt neg.chroms.txt && echo "Chromosome coverage matches." || echo "Mismatch in chromosome coverage!"

# 2. Check BED file coordinates fall within BigWig bounds
echo -e "\nValidating BED entries within BigWig bounds:"
awk '{print $1}' $BED | sort | uniq > bed.chroms.txt
comm -23 bed.chroms.txt <(cut -f1 pos.chroms.txt | sort) > missing_in_bw.txt

if [[ -s missing_in_bw.txt ]]; then
    echo "These BED chromosomes are not found in the bigwig:"
    cat missing_in_bw.txt
else
    echo "All BED chromosomes are present in the BigWig."
fi
