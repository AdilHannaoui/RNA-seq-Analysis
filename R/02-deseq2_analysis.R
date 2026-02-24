# ==========================
# RNA-seq DESeq2 analysis
# Author: Adil Hannaoui Anaaoui
# ==========================

# --------------------------
# Load configuration
# --------------------------
source("R/config.R") 

library(DESeq2)
library(dplyr)

# --------------------------
# Load data
# --------------------------
counts_matrix <- readRDS(COUNTS_MATRIX_PATH)    # counts matrix: genes x samples
colData <- readRDS(SAMPLE_METADATA_PATH)       # metadata: samples x conditions

# --------------------------
# Create DESeqDataSet
# --------------------------
dds <- DESeqDataSetFromMatrix(
  countData = counts_matrix,
  colData = colData,
  design = ~ condition
)

# --------------------------
# Filter low-count genes
# --------------------------
dds <- dds[rowSums(counts(dds)) > MIN_COUNTS_FILTER, ]

# --------------------------
# Set reference level
# --------------------------
dds$condition <- relevel(dds$condition, ref = REFERENCE_CONDITION)

# --------------------------
# Run DESeq2
# --------------------------
dds <- DESeq(dds)

# Generate and save results for each contrast
results_list <- list()

for (ct in CONTRASTS) {
  res     <- results(dds, contrast = c("condition", ct$treatment, REFERENCE_CONDITION))
  res_sig <- res[which(res$padj < PADJ_THRESHOLD), ]
  
  results_list[[ct$name]] <- list(full = res, sig = res_sig)
  
  saveRDS(res_sig, file = file.path(OUTPUT_DIR, paste0("DESeq2_", ct$name, "_sig.rds")))
  write.csv(as.data.frame(res_sig), file = file.path(OUTPUT_DIR, paste0("DESeq2_", ct$name, "_sig.csv")))
}

saveRDS(dds, file = file.path(OUTPUT_DIR, "dds.rds"))


cat("DESeq2 analysis completed. Significant results saved in:", OUTPUT_DIR, "\n")
