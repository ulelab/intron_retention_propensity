#!/bin/bash -l
#SBATCH --output=output.array.%A.%a
#SBATCH --job-name=umiextract
#SBATCH --mem=60G
#SBATCH --cpus-per-task=8
#SBATCH --array=1-90

# Activate your environment if needed
# conda activate umi-tools-env

# Define file list and get sample ID (e.g., SRR7657599)
FILE_LIST="sample_list.txt"
FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $FILE_LIST)

# Input: synced read 2 file
READ2="${FILE}_2.sync.fastq.gz"

# Output: UMI-tagged read 2
OUTPUT="${FILE}_2.umi_extracted.fastq.gz"

# Run umi_tools extract
umi_tools extract \
    -I "$READ2" \
    -S "$OUTPUT" \
    --bc-pattern=XXXXXNNNNNNXX \
    --extract-method=string \
    > "${FILE}.umi_extract.log"