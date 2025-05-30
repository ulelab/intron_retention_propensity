zcat /scratch/prj/ppn_rnp_networks/users/mike.jones/software/data-rstudio-server/PSI_TABLE-hg38.tab.gz | awk 'NR==1 || substr($2, 1, 5) == "HsaIN"' > PSI_HsaIN_only.tab

awk '
BEGIN { FS=OFS="\t" }
NR==1 {
  for (i=1; i<=NF; i++) {
    if ($i !~ /-Q$/) keep[i]=1;   # mark columns to keep
  }
}
{
  out = "";
  for (i=1; i<=NF; i++) {
    if (keep[i]) {
      out = out (out=="" ? $i : OFS $i);
    }
  }
  print out;
}' PSI_HsaIN_only.tab | gzip > PSI-Metadata.tab.gz