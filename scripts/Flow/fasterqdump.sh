#!/bin/bash -l
#SBATCH --output=/scratch/prj/ppn_rnp_networks/users/mike.jones/data/flash/
#SBATCH --job-name=fastdump
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --output=output.array.%A.%a
#SBATCH --array=1-90

input_file=`head accession.txt -n $SLURM_ARRAY_TASK_ID | tail -n 1`

fasterq-dump $input_file

wait
