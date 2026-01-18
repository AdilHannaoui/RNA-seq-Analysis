# ==========================
# RNA-seq Analysis Config
# Author: Adil Hannaoui Anaaoui
# ==========================

# --------------------------
# Project structure
# --------------------------
PROJECT_ROOT <- getwd()

DATA_DIR <- file.path(PROJECT_ROOT, "data")
OUTPUT_DIR <- file.path(PROJECT_ROOT, "output")

COUNTS_MATRIX_PATH <- "output/counts_matrix.rds"
SAMPLE_METADATA_PATH <- "output/colData.rds"
FEATURECOUNTS_DIR <- "output/featurecounts/"
PLOTS_DIR <- file.path(OUTPUT_DIR, "plots")
TABLES_DIR <- file.path(OUTPUT_DIR, "tables")

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
