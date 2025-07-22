#!/bin/bash
#SBATCH -p cpu
#SBATCH --time=120
#SBATCH --cpus-per-task=20
#SBATCH --mem=30G
#SBATCH -o PRPF8_to_bigwig.log
#SBATCH -e PRPF8_to_bigwig.err

# Sort the bedGraph first
sort -k1,1 -k2,2n -k3,3n /scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/PRPF8_eCLIP_RBPbinding_Prediction.collapsed.neg.bedgraph \
  > /scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/neg.sorted.bedgraph

# Convert to BigWig
bedGraphToBigWig /scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/neg.sorted.bedgraph \
  /scratch/prj/ppn_rnp_networks/shared/references/genomes/homo_sapiens/GRCh38.p14-GencodeRelease44/hg38.genome \
  /scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/PRPF8_eCLIP_RBPbinding_Prediction.neg.bw

