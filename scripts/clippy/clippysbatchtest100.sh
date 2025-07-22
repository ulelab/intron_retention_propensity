#!/bin/bash
#SBATCH --job-name=clippy_test
#SBATCH --output=clippy_test_%j.out
#SBATCH --error=clippy_test_%j.err
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=12
#SBATCH --mem=16G

# Activate the clippy conda environment
source /scratch/prj/ppn_rnp_networks/users/mike.jones/software/mambaforge/etc/profile.d/conda.sh
conda activate /scratch/prj/ppn_rnp_networks/users/mike.jones/software/mambaforge/envs/clippy

# Define input files and output prefix
BED=/scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/split_beds/f100/chr5.bed
GTF=/scratch/prj/ppn_rnp_networks/shared/references/genomes/homo_sapiens/GRCh38.p14-GencodeRelease44/gencode.v44.primary_assembly.annotation.gtf
FAI=/scratch/prj/ppn_rnp_networks/shared/references/genomes/homo_sapiens/GRCh38.p14-GencodeRelease44/GRCh38.primary_assembly.genome.fa.fai
OUTPREFIX=Prpf8_chr5_f100

# Run clippy
clippy -i "$BED" -o "$OUTPREFIX" \
       -a "$GTF" -g "$FAI"

