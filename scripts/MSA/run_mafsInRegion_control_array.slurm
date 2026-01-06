#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --array=1-10
#SBATCH --job-name=mafsInRegion_ctrl
#SBATCH --output=mafsInRegion_ctrl_%A_%a.out
#SBATCH --error=mafsInRegion_ctrl_%A_%a.err

# Paths - adjust these for your HPC
MAFSINREGION_BIN="/scratch/prj/ppn_rnp_networks/users/mike.jones/software/kent/src/mafsInRegion"
BED_PARTS_DIR="/scratch/prj/ppn_rnp_networks/users/mike.jones/data/maf/control_parts"
MAF_DIR="/scratch/prj/ppn_rnp_networks/users/mike.jones/data/maf/maf_files"
OUTPUT_DIR="/scratch/prj/ppn_rnp_networks/users/mike.jones/data/maf/ctrl_maf_output"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Get the bed file name for this array task (control_part1.bed, control_part2.bed, etc.)
BED_PART="control_part${SLURM_ARRAY_TASK_ID}.bed"
BED_FILE="${BED_PARTS_DIR}/${BED_PART}"

# Check if bed file exists
if [ ! -f "$BED_FILE" ]; then
    echo "ERROR: BED file not found: $BED_FILE"
    exit 1
fi

echo "=========================================="
echo "Task ${SLURM_ARRAY_TASK_ID}: Processing ${BED_PART}"
echo "BED file: $BED_FILE"
echo "Start time: $(date)"
echo "=========================================="

# Count sites in bed file
NUM_SITES=$(wc -l < "$BED_FILE")
echo "Number of sites: $NUM_SITES"
echo ""

# Extract unique chromosomes from the BED file (column 1)
UNIQUE_CHRS=$(cut -f1 "$BED_FILE" | sort -u)
echo "Unique chromosomes in this file:"
echo "$UNIQUE_CHRS"
echo ""

# Process each chromosome separately
for CHR_NAME in $UNIQUE_CHRS; do
    echo "----------------------------------------"
    echo "Processing chromosome: $CHR_NAME"
    
    # Determine MAF file based on chromosome
    MAF_FILE="${MAF_DIR}/${CHR_NAME}.maf.gz"
    
    # Check if MAF file exists
    if [ ! -f "$MAF_FILE" ]; then
        echo "WARNING: MAF file not found: $MAF_FILE, skipping chromosome $CHR_NAME"
        continue
    fi
    
    echo "MAF file: $MAF_FILE"
    
    # Create a temporary BED file with only entries for this chromosome
    TEMP_BED="${OUTPUT_DIR}/temp_${BED_PART%.bed}_${CHR_NAME}.bed"
    awk -v chr="$CHR_NAME" '$1 == chr' "$BED_FILE" > "$TEMP_BED"
    
    TEMP_SITES=$(wc -l < "$TEMP_BED")
    echo "Sites for $CHR_NAME: $TEMP_SITES"
    
    # Output directory for this chromosome (will create separate files per name)
    OUTPUT_SUBDIR="${OUTPUT_DIR}/${BED_PART%.bed}_${CHR_NAME}"
    mkdir -p "$OUTPUT_SUBDIR"
    
    echo "Output directory: $OUTPUT_SUBDIR"
    
    # Run mafsInRegion with -outDir to preserve BED name field (column 4)
    # Usage: mafsInRegion -outDir regions.bed outDir in.maf(s)
    # This creates separate .maf files named by the BED name field
    "$MAFSINREGION_BIN" -outDir "$TEMP_BED" "$OUTPUT_SUBDIR" "$MAF_FILE"
    
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo "SUCCESS: Processed $CHR_NAME"
        
        # Count output files created
        if [ -d "$OUTPUT_SUBDIR" ]; then
            OUTPUT_COUNT=$(find "$OUTPUT_SUBDIR" -name "*.maf" | wc -l)
            OUTPUT_SIZE=$(du -sh "$OUTPUT_SUBDIR" | cut -f1)
            echo "Output files created: $OUTPUT_COUNT"
            echo "Output directory size: $OUTPUT_SIZE"
        fi
    else
        echo "ERROR: Failed to process $CHR_NAME with exit code $EXIT_CODE"
    fi
    
    # Clean up temporary BED file
    rm -f "$TEMP_BED"
    
    echo ""
done

echo "=========================================="
echo "SUCCESS: Task ${SLURM_ARRAY_TASK_ID} completed"
echo "End time: $(date)"
echo "=========================================="

exit 0

