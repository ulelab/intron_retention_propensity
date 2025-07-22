#!/bin/bash -l
#SBATCH --output=repair.array.%A.%a
#SBATCH --job-name=repair_reads
#SBATCH --mem=60G
#SBATCH --cpus-per-task=8
#SBATCH --array=1-90

# Activate BBMap environment if needed
# conda activate bbmap-env

# Load sample name from sample list (e.g., SRR7657599)
FILE_LIST="sample_list.txt"
FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $FILE_LIST)

# Input FASTQ files
READ1="${FILE}_1.fastq.gz"
READ2="${FILE}_2.fastq.gz"

# Output: synchronised reads and singletons
OUT1="${FILE}_1.sync.fastq.gz"
OUT2="${FILE}_2.sync.fastq.gz"
SINGLES="${FILE}_singletons.fastq.gz"

# Run BBMap repair
repair.sh \
  in1="$READ1" \
  in2="$READ2" \
  out1="$OUT1" \
  out2="$OUT2" \
  outs="$SINGLES" \
  overwrite=t

