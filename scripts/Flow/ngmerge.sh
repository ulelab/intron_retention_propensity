#!/bin/bash -l

source ~/.bashrc
conda activate ngmerge-env

#SBATCH --output=merge.array.%A.%a
#SBATCH --job-name=ngmerge
#SBATCH --mem=60G
#SBATCH --cpus-per-task=8
#SBATCH --array=1-90
cd /scratch/prj/ppn_rnp_networks/users/mike.jones/data/flash/fastq

# Load sample ID from list
FILE_LIST="file_list.txt"
FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $FILE_LIST)

# Check if sample ID is valid
if [[ -z "$FILE" ]]; then
  echo "Error: SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_ID not valid for $FILE_LIST" >&2
  exit 1
fi

# Define file paths
READ1="/scratch/prj/ppn_rnp_networks/users/mike.jones/data/flash/fastq/${FILE}_1.umi_extracted.fastq.gz"
READ2="/scratch/prj/ppn_rnp_networks/users/mike.jones/data/flash/fastq/${FILE}_2.umi_extracted.fastq.gz"
OUTPUT_PREFIX="${FILE}_merged"

# Check that input files exist
if [[ ! -f "$READ1" || ! -f "$READ2" ]]; then
  echo "Missing input FASTQ: $READ1 or $READ2" >&2
  exit 1
fi

# Create logs directory if needed
mkdir -p logs

# Run NGmerge
echo "Running NGmerge for $FILE"
ngmerge -1 "$READ1" -2 "$READ2" -o "$OUTPUT_PREFIX" -v &> "logs/${FILE}_ngmerge.log"

# Check status
if [[ $? -eq 0 ]]; then
  echo "NGmerge completed successfully for $FILE"
else
  echo "NGmerge failed for $FILE. Check logs/${FILE}_ngmerge.log" >&2
  exit 1
fi

