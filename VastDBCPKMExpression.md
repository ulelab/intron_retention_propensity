---
title: "VastDBExpression"
author: "Michael K. Jones"
output: html_document
---

# VastDB Exploration of Intron Retention Part 2

## Determine relationship of PSI and cRPKM in each cluster

```{r}

library(ggplot2)
library(data.table)

expressionTable <- fread("EXPRESSION_TABLE-hg38.tab.gz")
# eventInfo <- fread("EVENT_INFO-hg38.tab.gz")
# eventMetrics <- fread("EVENT_METRICS-hg38.tab.gz")
psiTable <- fread("PSI_TABLE-hg38.tab.gz")
```

```{r}
# Create table containing only IR events, merge with summary statistics for exploration
psiHsaIN <- psiTable[grep("^HsaIN", psiTable$EVENT), ]
rownames(psiHsaIN) <- psiHsaIN$GENE
rn <- rownames(psiHsaIN)

# Remove Meta data and Quality measures(-Q$)
metaPsi <- psiHsaIN[, !grepl("-Q$", colnames(psiHsaIN)), with = FALSE]
meta_cols <- c("EVENT", "GENE", "COORD", "LENGTH", "FullCO", "COMPLEX")
rownames(metaPsi) <- rn

# Create cleaned version of expressionTable
expressionClean <- expressionTable[, !("ID"), with = FALSE]
setnames(expressionClean, "NAME", "GENE")

# Add _PSI to PSI columns
psiClean <- copy(metaPsi)
psiColsToRename <- colnames(psiClean)[7:151]
setnames(psiClean, psiColsToRename, paste0(psiColsToRename, "_PSI"))

# Identify rows where every value is NA and remove those rows for both meta and values Psi tables
all_na_rows <- apply(metaPsi[, 7:151], 1, function(x) all(is.na(x)))
metaPsi <- metaPsi[!all_na_rows, ]

# Reset row names
rownames(metaPsi) <- metaPsi$GENE
```

```{r}

# Convert to matrix and preserve rownames
valuesPsi <- metaPsi[, !colnames(metaPsi) %in% meta_cols, with = FALSE]
valuesMatrix <- as.matrix(valuesPsi)
rownames(valuesMatrix) <- rownames(metaPsi)

# Filter rows with >80% NAs
rowNAfraction <- rowMeans(is.na(valuesMatrix))
filteredMatrix <- valuesMatrix[rowNAfraction < 0.8, ]
rownames(filteredMatrix) <- rownames(valuesMatrix)[rowNAfraction < 0.8]

# Impute NAs using row medians
imputeMatrix <- filteredMatrix  # copy to preserve original NA structure
for (i in 1:nrow(imputeMatrix)) {
  row_na <- is.na(imputeMatrix[i, ])
  if (any(row_na)) {
    imputeMatrix[i, row_na] <- median(imputeMatrix[i, ], na.rm = TRUE)
  }
}

# K-means clustering (k = 4) on imputed matrix
set.seed(43)
kmeansRes <- kmeans(imputeMatrix, centers = 4)
clusterLabels <- data.frame(cluster = factor(paste0("Cluster_", kmeansRes$cluster),
                                             levels = paste0("Cluster_", 1:4)))
rownames(clusterLabels) <- rownames(imputeMatrix)

# Order matrix rows by cluster
orderedRows <- rownames(clusterLabels)[order(clusterLabels$cluster)]
matrixOrdered <- filteredMatrix[orderedRows, ]
rowAnnotOrdered <- clusterLabels[orderedRows, , drop = FALSE]

mergedPsiExpression <- merge(psiClean, expressionClean, by = "GENE", all.x = TRUE)

# Count number of unique genes in the merged table
uniqueGeneCount <- length(unique(mergedPsiExpression$GENE))
print(uniqueGeneCount)

# Match tissues by name
allCols <- colnames(mergedPsiExpression)
psiCols <- grep("_PSI$", allCols, value = TRUE)
exprCols <- grep("-cRPKM$", allCols, value = TRUE)

psiTissueNames <- sub("_PSI$", "", psiCols)
exprTissueNames <- sub("-cRPKM$", "", exprCols)
matchedTissues <- intersect(psiTissueNames, exprTissueNames)

# Create a named list of column pairs
colPairs <- setNames(
  lapply(matchedTissues, function(tissue) {
    list(psi = paste0(tissue, "_PSI"), expr = paste0(tissue, "-cRPKM"))
  }),
  matchedTissues
)

```
