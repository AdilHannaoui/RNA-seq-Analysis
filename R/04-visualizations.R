# ==========================
# RNA-seq visualization
# Author: Adil Hannaoui Anaaoui
# ==========================

# --------------------------
# Load libraries
# --------------------------
library(DESeq2)
library(tidyverse)
library(pheatmap)
library(ggplot2)
library(gridExtra)
library(grid)
library(clusterProfiler)
library(org.Sc.sgd.db)
library(enrichplot)

# --------------------------
# Load configuration
# --------------------------
source("config.R")

# --------------------------
# Load precomputed objects
# --------------------------
dds <- readRDS(file.path(OUTPUT_DIR, "dds.rds"))
res_WT_vs_A <- readRDS(file.path(OUTPUT_DIR, "DESeq2_WT_vs_A_sig.rds"))
res_WT_vs_D <- readRDS(file.path(OUTPUT_DIR, "DESeq2_WT_vs_D_sig.rds"))
enrich_WT_vs_A_over <- readRDS(file.path(OUTPUT_DIR, "enrich_over_WT_vs_A.rds"))
enrich_WT_vs_A_under <- readRDS(file.path(OUTPUT_DIR, "enrich_under_WT_vs_A.rds"))
enrich_WT_vs_D_over <- readRDS(file.path(OUTPUT_DIR, "enrich_over_WT_vs_D.rds"))
enrich_WT_vs_D_under <- readRDS(file.path(OUTPUT_DIR, "enrich_under_WT_vs_D.rds"))

# --------------------------
# 1. MA plots
# --------------------------
pdf(file.path(PLOTS_DIR, "MA_WT_vs_A.pdf"))
plotMA(res_WT_vs_A, main="MA Plot WT vs A", ylim=c(-5,5))
dev.off()

pdf(file.path(PLOTS_DIR, "MA_WT_vs_D.pdf"))
plotMA(res_WT_vs_D, main="MA Plot WT vs D", ylim=c(-5,5))
dev.off()

# --------------------------
# 2. PCA plot
# --------------------------
vsd <- vst(dds, blind=FALSE)
pdf(file.path(PLOTS_DIR, "PCA_all_samples.pdf"))
plotPCA(vsd, intgroup="condition")
dev.off()

# --------------------------
# 3. Heatmap of top 50 genes (WT vs A)
# --------------------------
top50_genes <- head(order(res_WT_vs_A$padj), 50)
mat <- assay(vsd)[top50_genes, ]
annotation <- as.data.frame(colData(dds)[, "condition", drop=FALSE])

pdf(file.path(PLOTS_DIR, "Heatmap_top50_WT_vs_A.pdf"))
pheatmap(mat, annotation_col = annotation, scale="row", show_rownames=FALSE,
         main="Top 50 DE genes WT vs A")
dev.off()

# --------------------------
# 4. Volcano plots
# --------------------------
volcano_plot <- function(res, title){
  res_df <- as.data.frame(res)
  res_df$Significant <- ifelse(res_df$padj < 0.05 & abs(res_df$log2FoldChange) > 1, 
                               ifelse(res_df$log2FoldChange > 1, "Up", "Down"), "NS")
  
  ggplot(res_df, aes(x=log2FoldChange, y=-log10(padj), color=Significant)) +
    geom_point(alpha=0.6) +
    scale_color_manual(values=c("Down"="blue","NS"="grey","Up"="red")) +
    theme_minimal() +
    ggtitle(title)
}

pdf(file.path(PLOTS_DIR, "Volcano_WT_vs_A.pdf"))
volcano_plot(res_WT_vs_A, "WT vs A")
dev.off()

pdf(file.path(PLOTS_DIR, "Volcano_WT_vs_D.pdf"))
volcano_plot(res_WT_vs_D, "WT vs D")
dev.off()

# --------------------------
# 5. GO enrichment dotplots
# --------------------------
pdf(file.path(PLOTS_DIR, "GO_WT_vs_A.pdf"), width=12, height=6)
grid.arrange(
  dotplot(enrich_WT_vs_A_under, showCategory=10) + ggtitle("Underexpressed"),
  dotplot(enrich_WT_vs_A_over, showCategory=10) + ggtitle("Overexpressed"),
  ncol=2,
  top=textGrob("GO enrichment WT vs A", gp=gpar(fontsize=16, fontface="bold"))
)
dev.off()

pdf(file.path(PLOTS_DIR, "GO_WT_vs_D.pdf"), width=12, height=6)
grid.arrange(
  dotplot(enrich_WT_vs_D_under, showCategory=10) + ggtitle("Underexpressed"),
  dotplot(enrich_WT_vs_D_over, showCategory=10) + ggtitle("Overexpressed"),
  ncol=2,
  top=textGrob("GO enrichment WT vs D", gp=gpar(fontsize=16, fontface="bold"))
)
dev.off()
