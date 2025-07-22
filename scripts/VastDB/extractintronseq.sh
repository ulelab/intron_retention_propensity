zcat PSI-Metadata.tab.gz | awk -F'\t' 'NR > 1 {
  split($3, a, "[:-]");
  strand = substr($5, length($5), 1);  # last character of FullCO
  print a[1] "\t" a[2]-1 "\t" a[3] "\t" $1 "\t0\t" strand;
}' > introns.bed

cut -f1,2 /scratch/prj/ppn_rnp_networks/shared/references/genomes/homo_sapiens/GRCh38.p14-GencodeRelease44/GRCh38.primary_assembly.genome.fa.fai > /scratch/prj/ppn_rnp_networks/shared/references/genomes/homo_sapiens/GRCh38.p14-GencodeRelease44/hg38.genome

bedtools slop \
  -i /scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/introns.bed \
  -g /scratch/prj/ppn_rnp_networks/shared/references/genomes/homo_sapiens/GRCh38.p14-GencodeRelease44/GRCh38.primary_assembly.genome.fa.fai \
  -b 50 \
  > /scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/introns_flank50.bed

bedtools getfasta \
  -fi /scratch/prj/ppn_rnp_networks/shared/references/genomes/homo_sapiens/GRCh38.p14-GencodeRelease44/GRCh38.primary_assembly.genome.fa \
  -bed /scratch/prj/ppn_rnp_networks/users/mike.jones/data/rbpnet/introns_flank50.bed \
  -s -name \
  -fo /scratch/prj/ppn_rnp_networks/users/mike.jones/data/splice/rbpseq.fa
