# ==========================
# RNA-seq Analysis Config
# Author: Adil Hannaoui Anaaoui
# ==========================

# --------------------------
# Project structure
# --------------------------
PROJECT_ROOT <- getwd()

DATA_DIR <- file.path(PROJECT_ROOT, "data")
RESULTS_DIR <- file.path(PROJECT_ROOT, "results")

COUNTS_MATRIX_PATH <- "data/counts_matrix.csv"
RESULTS_DIR <- "results"
PLOTS_DIR <- file.path(RESULTS_DIR, "plots")
TABLES_DIR <- file.path(RESULTS_DIR, "tables")

# --------------------------
# Experimental design
# --------------------------
CONDITIONS <- c(
  rep("WT", 6),
  rep("A", 3),
  rep("D", 3)
)

REFERENCE_CONDITION <- "WT"

# --------------------------
# DESeq2 parameters
# --------------------------
PADJ_THRESHOLD <- 0.05
LOG2FC_THRESHOLD <- 1
MIN_COUNTS_FILTER <- 10

# --------------------------
# Enrichment analysis
# --------------------------
GO_ONTOLOGY <- "BP" 
PVAL_CUTOFF <- 0.05
QVAL_CUTOFF <- 0.05

# --------------------------
# Organism database
# --------------------------
ORG_DB <- "org.Sc.sgd.db"
GENE_ID_TYPE <- "ORF" 
