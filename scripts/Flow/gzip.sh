#!/bin/bash -l
#SBATCH --job-name=gzipping
#SBATCH --partition=cpu
#SBATCH --ntasks=1
#SBATCH --mem=60G
#SBATCH --cpus-per-task=8

gzip *.fastq
