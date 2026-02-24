# ==========================
# RNA-seq visualization
# Author: Adil Hannaoui Anaaoui
# ==========================

# --------------------------
# Load libraries
# --------------------------
suppressPackageStartupMessages({
  library(DESeq2)
  library(ggplot2)
  library(pheatmap)
  library(gridExtra)
  library(grid)
  library(clusterProfiler)
  library(org.Sc.sgd.db)
  library(enrichplot)
})

# --------------------------
# Load configuration
# --------------------------
source("R/config.R")

# --------------------------
# Helper functions
# --------------------------

# Safe PNG wrapper: skips plot if condition not met, warns user
safe_plot <- function(path, expr, skip_condition = FALSE, skip_msg = NULL,
                      width = 8, height = 6, units = "in", res = 200) {
  if (skip_condition) {
    warning(skip_msg)
    message("  ⚠ Skipped: ", basename(path), " — ", skip_msg)
    return(invisible(NULL))
  }
  tryCatch({
    png(path, width = width, height = height, units = units, res = res)
    force(expr)
    dev.off()
    message("  ✓ Saved: ", basename(path))
  }, error = function(e) {
    dev.off()
    warning("Failed to generate plot '", basename(path), "': ", e$message)
    message("  ✗ Failed: ", basename(path), " — ", e$message)
  })
}

volcano_plot <- function(res, title) {
  res_df <- as.data.frame(res)
  res_df$Significant <- ifelse(
    res_df$padj < PADJ_THRESHOLD & abs(res_df$log2FoldChange) > LOG2FC_THRESHOLD,
    ifelse(res_df$log2FoldChange > LOG2FC_THRESHOLD, "Up", "Down"),
    "NS"
  )
  ggplot(res_df, aes(x = log2FoldChange, y = -log10(padj), color = Significant)) +
    geom_point(alpha = 0.6) +
    scale_color_manual(values = c("Down" = "blue", "NS" = "grey", "Up" = "red")) +
    theme_minimal() +
    ggtitle(title)
}

# Check if enrichment result is plottable (non-null and has results)
has_enrichment <- function(enrich_obj) {
  !is.null(enrich_obj) && nrow(enrich_obj@result) > 0
}

# --------------------------
# Load precomputed objects
# --------------------------
message("\n--- Loading precomputed objects ---")

dds <- readRDS(file.path(OUTPUT_DIR, "dds.rds"))

# Load full (unfiltered) DESeq2 results per contrast for MA/volcano/heatmap
results_list <- list()
for (ct in CONTRASTS) {
  rds_path <- file.path(OUTPUT_DIR, paste0("DESeq2_", ct$name, "_sig.rds"))
  if (file.exists(rds_path)) {
    results_list[[ct$name]] <- readRDS(rds_path)
    message("  ✓ Loaded DESeq2 results: ", ct$name)
  } else {
    warning("Full results RDS not found for contrast '", ct$name, "': ", rds_path)
    message("  ⚠ Missing: DESeq2_", ct$name, "_sig.rds — MA and Volcano plots will be skipped")
    results_list[[ct$name]] <- NULL
  }
}

# --------------------------
# Per-contrast plots
# --------------------------
message("\n--- Generating per-contrast plots ---")

for (ct in CONTRASTS) {
  message("\nContrast: ", ct$label)
  res_full <- results_list[[ct$name]]
  
  # -- MA plot --
  safe_plot(
    path           = file.path(PLOTS_DIR, paste0("MA_", ct$name, ".png")),
    skip_condition = is.null(res_full),
    skip_msg       = paste("No DESeq2 results available for", ct$name),
    expr           = plotMA(res_full, main = paste("MA Plot", ct$label), ylim = c(-5, 5))
  )
  
  # -- Volcano plot --
  res_df <- if (!is.null(res_full)) as.data.frame(res_full) else NULL
  has_finite <- !is.null(res_df) && any(is.finite(res_df$padj) & is.finite(res_df$log2FoldChange))
  
  safe_plot(
    path           = file.path(PLOTS_DIR, paste0("Volcano_", ct$name, ".png")),
    skip_condition = !has_finite,
    skip_msg       = paste("No finite padj/log2FC values for volcano in", ct$name),
    expr           = print(volcano_plot(res_full, ct$label))
  )
  
  # -- GO enrichment dotplot --
  over_path  <- file.path(OUTPUT_DIR, paste0("enrich_over_",  ct$name, ".rds"))
  under_path <- file.path(OUTPUT_DIR, paste0("enrich_under_", ct$name, ".rds"))
  
  enrich_over  <- if (file.exists(over_path))  readRDS(over_path)  else NULL
  enrich_under <- if (file.exists(under_path)) readRDS(under_path) else NULL
  
  has_over  <- has_enrichment(enrich_over)
  has_under <- has_enrichment(enrich_under)
  
  if (!has_over && !has_under) {
    safe_plot(
      path           = file.path(PLOTS_DIR, paste0("GO_", ct$name, ".png")),
      skip_condition = TRUE,
      skip_msg       = paste("No enrichment results (over or under) for", ct$name)
    )
  } else {
    # Build only the panels that have data
    plots <- list()
    if (has_under) plots[["under"]] <- dotplot(enrich_under, showCategory = 10) + ggtitle("Underexpressed")
    if (has_over)  plots[["over"]]  <- dotplot(enrich_over,  showCategory = 10) + ggtitle("Overexpressed")
    
    safe_plot(
      path   = file.path(PLOTS_DIR, paste0("GO_", ct$name, ".png")),
      width  = 12, height = 8,
      expr   = grid.arrange(
        grobs = plots,
        ncol  = length(plots),
        top   = textGrob(
          paste("GO enrichment", ct$label),
          gp = gpar(fontsize = 16, fontface = "bold")
        )
      )
    )
  }
}

# --------------------------
# PCA (all samples)
# --------------------------
message("\n--- PCA plot ---")

safe_plot(
  path = file.path(PLOTS_DIR, "PCA_all_samples.png"),
  expr = {
    vsd <- vst(dds, blind = FALSE)
    print(plotPCA(vsd, intgroup = "condition"))
  }
)

# --------------------------
# Heatmap (top 50 DE genes, first contrast)
# --------------------------
message("\n--- Heatmap ---")

res_ref  <- results_list[[CONTRASTS[[1]]$name]]
has_padj <- !is.null(res_ref) && any(is.finite(res_ref$padj))

safe_plot(
  path           = file.path(PLOTS_DIR, "Heatmap_top50.png"),
  skip_condition = !has_padj,
  skip_msg       = "No finite padj values in reference contrast — heatmap skipped",
  expr = {
    vsd        <- vst(dds, blind = FALSE)
    top50      <- head(order(res_ref$padj), 50)
    mat        <- assay(vsd)[top50, ]
    annotation <- as.data.frame(colData(dds)[, "condition", drop = FALSE])
    pheatmap(mat, annotation_col = annotation, scale = "row",
             show_rownames = FALSE, main = "Top 50 DE genes")
  }
)

message("\n✓ Visualization complete")
