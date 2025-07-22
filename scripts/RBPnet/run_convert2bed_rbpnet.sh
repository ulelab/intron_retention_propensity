#!/bin/bash
#SBATCH -p cpu
#SBATCH --mem=48G
#SBATCH --cpus-per-task=30
#SBATCH --time=240
#SBATCH -o myscript.log

# Initialise conda
source /scratch/prj/ppn_rnp_networks/users/mike.jones/software/mambaforge/etc/profile.d/conda.sh
conda activate rbpnet-env

# Run your script
python3 /scratch/prj/ppn_rnp_networks/users/mike.jones/scripts/Convert_PRPF8TSV_2bed.py

