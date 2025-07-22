#!/bin/bash -l
#SBATCH --job-name=rbpnet_train
#SBATCH --output=rbpnet_train.out
#SBATCH --error=rbpnet_train.err
#SBATCH --time=48:00:00
#SBATCH --gres=gpu

# Run training
rbpnet train -d dataspec.yml -o /scratch/prj/ppn_rnp_networks/users/mike.jones/software/RBPnet/ train.tfrecord
