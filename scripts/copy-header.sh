#!/bin/bash -l
#SBATCH --output=headerfix.array.%A.%a
#SBATCH --job-name=headerrun
#SBATCH --mem=20G
#SBATCH --cpus-per-task=8
#SBATCH --array=1-90

# Define file list and get sample ID
FILE_LIST="sample_list.txt"
FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $FILE_LIST)

# Run the Python script
python /scratch/prj/ppn_rnp_networks/users/mike.jones/scripts/copy_fastq_header.py "$FILE"
