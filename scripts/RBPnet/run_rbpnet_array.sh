#!/bin/bash
#SBATCH --job-name=rbpnet_batch_array
#SBATCH --time=30:00:00
#SBATCH --mem=60G
#SBATCH --cpus-per-task=12
#SBATCH --array=1-64
#SBATCH --output=/scratch/prj/ppn_rnp_networks/users/mike.jones/software/rbpnet/logs/batch_%A_%a.out
#SBATCH --error=/scratch/prj/ppn_rnp_networks/users/mike.jones/software/rbpnet/logs/batch_%A_%a.err

# Activate conda
source /scratch/prj/ppn_rnp_networks/users/mike.jones/software/mambaforge/etc/profile.d/conda.sh
conda activate rbpnet-env

# Set paths
TSV_FILE="/scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/batches.tsv"
OUTPUT_DIR="/scratch/prj/ppn_rnp_networks/users/mike.jones/software/rbpnet/pred"
INPUT_DIR="/scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/split_batches"

# Get the correct line
LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$TSV_FILE")
BASENAME=$(basename "$LINE" .fa)
OUT_FILE="$OUTPUT_DIR/${BASENAME}.tsv"

echo "Running RBPNet on: $LINE"
rbpnet predict -m /scratch/prj/ppn_rnp_networks/users/mike.jones/software/rbpnet/models/PRPF8_HepG2.model.h5 -o "$OUT_FILE" --format fasta "$INPUT_DIR/$LINE"
echo "Finished: $BASENAME"

