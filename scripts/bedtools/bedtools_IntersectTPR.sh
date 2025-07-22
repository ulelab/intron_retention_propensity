bedtools intersect \
  -a ../rbpnet/peaks/f50/rbpnet_clippy_f50_rollmean10_minHeightAdjust1.0_minPromAdjust1.0_minGeneCount5_Peaks.bed \
  -b ../rbpnet/Canonical_splice_sites.bed \
     ../splice/Splice_All.filtered.2e-4.bed \
     ../eCLIP/PRPF8_eCLIP_HepG2_rollmean10_minHeightAdjust1.0_minPromAdjust1.0_minGeneCount5_Peaks.bed \
     ../prpf8/PRPF8_iCLIP_HepG2_xlinks.bed \
  -c \
  -filenames \
  > Intersect_f50_TPR_AllSpliceSites_eiCLIP.bed

