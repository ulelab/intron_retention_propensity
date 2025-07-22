#!/bin/bash
#SBATCH --job-name=spliceai_batch_array
#SBATCH --time=30:00:00
#SBATCH --gres=gpu
#SBATCH --array=1-64
#SBATCH --output=/scratch/prj/ppn_rnp_networks/users/mike.jones/software/spliceAI/logs/batch_%A_%a.out
#SBATCH --error=/scratch/prj/ppn_rnp_networks/users/mike.jones/software/spliceAI/logs/batch_%A_%a.err

# Activate conda
source /scratch/prj/ppn_rnp_networks/users/mike.jones/software/mambaforge/etc/profile.d/conda.sh
conda activate spliceai-env

# Set input TSV
TSV_FILE="/scratch/prj/ppn_rnp_networks/users/mike.jones/data/splice/batches.tsv"

# Get current batch file
LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$TSV_FILE")

# Run prediction script on this batch
python /scratch/prj/ppn_rnp_networks/users/mike.jones/software/spliceAI/splicedpred.py "$LINE"

