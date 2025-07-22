sort -k1,1 -k2,2n -k3,3n PRPF8_eCLIP_RBPbinding_Prediction.pos.bedgraph > sorted.bedgraph

awk -F'\t' '
{
  key = $1 FS $2 FS $3
  sum[key] += $4
  count[key] += 1
}
END {
  for (k in sum) {
    split(k, a, FS)
    avg = sum[k] / count[k]
    printf "%s\t%s\t%s\t%.6f\n", a[1], a[2], a[3], avg
  }
}' sorted.bedgraph > PRPF8_eCLIP_RBPbinding_Prediction.collapsed.pos.bedgraph
