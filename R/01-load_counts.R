# ==========================
# RNA-seq counts preparation
# Author: Adil Hannaoui Anaaoui
# ==========================

library(tidyverse)

# --------------------------
# 1. List all featureCounts files
# --------------------------
setwd('data/folder/')
files <- list.files("featurecounts/", pattern="Counts_.*\\.txt$", full.names = TRUE)

# --------------------------
# 2. Read all files into a list
# --------------------------
counts_list <- lapply(files, function(f) {
  read_table(f) %>%
    select(Geneid, counts = 2)  # assuming column 2 is the counts column
})

# Use file names (without extension) as names
names(counts_list) <- basename(files) %>% tools::file_path_sans_ext()

# --------------------------
# 3. Identify common genes
# --------------------------
common_genes <- Reduce(intersect, lapply(counts_list, `[[`, "Geneid"))

# --------------------------
# 4. Build counts matrix
# --------------------------
counts_matrix <- sapply(counts_list, function(df) {
  df %>% filter(Geneid %in% common_genes) %>% pull(counts)
})

rownames(counts_matrix) <- common_genes
