# ==========================
# RNA-seq GO enrichment analysis
# Author: Adil Hannaoui Anaaoui
# ==========================

library(DESeq2)
library(tidyverse)
library(clusterProfiler)
library(org.Sc.sgd.db)
library(enrichplot)
library(gridExtra)
library(grid)

# --------------------------
# 1. Load config
# --------------------------
source("R/config.R")  # contiene rutas, log2FC_threshold, ontología, etc.

# --------------------------
# 2. Load DESeq2 results
# --------------------------
res_WT_vs_A <- readRDS(file.path(OUTPUT_DIR, "DESeq2_WT_vs_A_sig.rds"))
res_WT_vs_D <- readRDS(file.path(OUTPUT_DIR, "DESeq2_WT_vs_D_sig.rds"))

# --------------------------
# 3. Function to perform GO enrichment
# --------------------------
perform_enrichGO <- function(res, comparison_name) {
  
  gene_list <- res$log2FoldChange
  names(gene_list) <- rownames(res)
  
  # Convert ENSEMBL IDs to ENTREZ
  gene_list_entrez <- bitr(names(gene_list), fromType="ENSEMBL",
                           toType="ENTREZID", OrgDb=org.Sc.sgd.db)
  
  # Keep only mapped genes
  gene_list <- gene_list[gene_list_entrez$ENSEMBL %in% names(gene_list)]
  names(gene_list) <- gene_list_entrez$ENTREZID[match(names(gene_list),
                                                      gene_list_entrez$ENSEMBL)]
  
  # Define over- and under-expressed genes
  over_genes <- names(gene_list[gene_list > LOG2FC_THRESHOLD])
  under_genes <- names(gene_list[gene_list < -LOG2FC_THRESHOLD])
  
  # Enrichment
  enrich_over <- enrichGO(gene = over_genes, OrgDb = org.Sc.sgd.db,
                          ont = GO_ONTOLOGY, pvalueCutoff = PADJ_THRESHOLD)
  
  enrich_under <- enrichGO(gene = under_genes, OrgDb = org.Sc.sgd.db,
                           ont = GO_ONTOLOGY, pvalueCutoff = PADJ_THRESHOLD)
  
  # Save results
  saveRDS(enrich_over, file=file.path(OUTPUT_DIR, paste0("enrich_over_", comparison_name, ".rds")))
  saveRDS(enrich_under, file=file.path(OUTPUT_DIR, paste0("enrich_under_", comparison_name, ".rds")))
  write.csv(as.data.frame(enrich_over), file.path(OUTPUT_DIR, paste0("enrich_over_", comparison_name, ".csv")))
  write.csv(as.data.frame(enrich_under), file.path(OUTPUT_DIR, paste0("enrich_under_", comparison_name, ".csv")))
  
  # Return for plotting if needed
  list(over = enrich_over, under = enrich_under)
}

# --------------------------
# 4. Run enrichment for each comparison
# --------------------------
enrich_WT_vs_A <- perform_enrichGO(res_WT_vs_A, "WT_vs_A")
enrich_WT_vs_D <- perform_enrichGO(res_WT_vs_D, "WT_vs_D")

