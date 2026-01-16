# ==========================
# RNA-seq DESeq2 analysis
# Author: Adil Hannaoui Anaaoui
# ==========================

# --------------------------
# Load configuration
# --------------------------
source("config.R")  # define aquí: counts_matrix_path, sample_metadata_path, output_dir, min_counts

library(DESeq2)
library(tidyverse)

# --------------------------
# Load data
# --------------------------
counts_matrix <- readRDS(counts_matrix_path)    # counts matrix: genes x samples
colData <- readRDS(sample_metadata_path)       # metadata: samples x conditions

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
dds <- dds[rowSums(counts(dds)) > min_counts, ]

# --------------------------
# Set reference level
# --------------------------
dds$condition <- relevel(dds$condition, ref = reference_condition)

# --------------------------
# Run DESeq2
# --------------------------
dds <- DESeq(dds)

# --------------------------
# Extract results for contrasts
# --------------------------
res_WT_vs_A <- results(dds, contrast = c("condition", "A", reference_condition))
res_WT_vs_D <- results(dds, contrast = c("condition", "D", reference_condition))

# --------------------------
# Filter significant genes
# --------------------------
res_WT_vs_A_sig <- res_WT_vs_A[which(res_WT_vs_A$padj < p_adj_cutoff), ]
res_WT_vs_D_sig <- res_WT_vs_D[which(res_WT_vs_D$padj < p_adj_cutoff), ]

# --------------------------
# Save results
# --------------------------
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

saveRDS(res_WT_vs_A_sig, file = file.path(output_dir, "DESeq2_WT_vs_A_sig.rds"))
saveRDS(res_WT_vs_D_sig, file = file.path(output_dir, "DESeq2_WT_vs_D_sig.rds"))

write.csv(as.data.frame(res_WT_vs_A_sig), file = file.path(output_dir, "DESeq2_WT_vs_A_sig.csv"))
write.csv(as.data.frame(res_WT_vs_D_sig), file = file.path(output_dir, "DESeq2_WT_vs_D_sig.csv"))

cat("DESeq2 analysis completed. Significant results saved in:", output_dir, "\n")
