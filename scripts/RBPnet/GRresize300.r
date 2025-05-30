#!/usr/bin/env Rscript

# Load required libraries
suppressMessages({
    library(GenomicRanges)
    library(rtracklayer)
})

# Input and output file paths
input_bed <- "PRPF8_rollmean10_minHeightAdjust4.0_minPromAdjust1.5_minGeneCount5_Peaks.bed"
output_bed <- "PRPF8_peaks_300bp.bed"
fai_file <- "Homo_sapiens.GRCh38.fasta.fai"

# Import BED
bed <- import(input_bed)

# Resize to 300 bp centered on each interval
bed_fixed <- resize(bed, width = 300, fix = "center")

# Read FAI and extract only matching chromosomes
fai <- read.table("Homo_sapiens.GRCh38.fasta.fai", stringsAsFactors = FALSE)
chr_lengths <- setNames(fai$V2, fai$V1)

# Subset to GRanges seqlevels
chr_lengths <- chr_lengths[seqlevels(bed_fixed)]

# Now assign and trim
seqlengths(bed_fixed) <- chr_lengths
bed_trimmed <- trim(bed_fixed)

# Filter out any with negative starts (shouldn't occur with trim, but safe)
bed_final <- bed_trimmed[start(bed_trimmed) >= 0]

# Export the modified BED
export(bed_final, output_bed)
