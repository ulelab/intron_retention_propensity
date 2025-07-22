#!/bin/bash
#SBATCH --job-name=clippy_rbpnet_100
#SBATCH --output=clippy_rbpnet_100_%A_%a.out
#SBATCH --error=clippy_rbpnet_100_%A_%a.err
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=12
#SBATCH --mem=16G
#SBATCH --array=1-24

# Activate the clippy conda environment
source /scratch/prj/ppn_rnp_networks/users/mike.jones/software/mambaforge/etc/profile.d/conda.sh
conda activate /scratch/prj/ppn_rnp_networks/users/mike.jones/software/mambaforge/envs/clippy

# Chromosome mapping: 1–22 and X
CHR=$(sed -n "${SLURM_ARRAY_TASK_ID}p" chroms.txt)

# Define input and output
BED=/scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/split_beds/f100/${CHR}
GTF=/scratch/prj/ppn_rnp_networks/shared/references/genomes/homo_sapiens/GRCh38.p14-GencodeRelease44/gencode.v44.primary_assembly.annotation.gtf
FAI=/scratch/prj/ppn_rnp_networks/shared/references/genomes/homo_sapiens/GRCh38.p14-GencodeRelease44/GRCh38.primary_assembly.genome.fa.fai
OUTDIR=/scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/peaks/f100/
OUTPREFIX=${OUTDIR}/rbpnet_clippy_f100_${CHR}

# Run clippy
clippy -i "$BED" -o "$OUTPREFIX" \
       -a "$GTF" -g "$FAI" \
