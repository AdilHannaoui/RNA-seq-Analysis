# ==========================
# RNA-seq Analysis Config
# Author: Adil Hannaoui Anaaoui
# ==========================

# Suppress startup messages
suppressPackageStartupMessages({
  library(tools)
})

# --------------------------
# Project structure
# --------------------------
# Get script directory robustly
get_project_root <- function() {
  # Try multiple methods to find project root
  
  # Method 1: from sourced script
  if (exists("ofile", where = sys.frame(1))) {
    script_path <- sys.frame(1)$ofile
    if (!is.null(script_path)) {
      return(normalizePath(file.path(dirname(script_path), "..")))
    }
  }
  
  # Method 2: from Rscript command line
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    script_path <- sub("^--file=", "", file_arg)
    return(normalizePath(file.path(dirname(script_path), "..")))
  }
  
  # Method 3: current working directory
  message("Warning: Using current working directory as project root")
  return(getwd())
}

PROJECT_ROOT <- get_project_root()
DATA_DIR <- file.path(PROJECT_ROOT, "data")
OUTPUT_DIR <- file.path(PROJECT_ROOT, "output")
COUNTS_MATRIX_PATH <- file.path(OUTPUT_DIR, "counts_matrix.rds")
SAMPLE_METADATA_PATH <- file.path(OUTPUT_DIR, "colData.rds")
FEATURECOUNTS_DIR <- file.path(OUTPUT_DIR, "featurecounts")
PLOTS_DIR <- file.path(PROJECT_ROOT, "Plots")
TABLES_DIR <- file.path(OUTPUT_DIR, "tables")

# --------------------------
# Experimental design
# --------------------------
CONDITIONS <- c(
  rep("Rpb4-S/T-A", 3),
  rep("Rpb4-Δ", 3),
  rep("WT", 6)
)

REFERENCE_CONDITION <- "WT"

# Validate reference condition
if (!REFERENCE_CONDITION %in% CONDITIONS) {
  stop("REFERENCE_CONDITION '", REFERENCE_CONDITION, 
       "' not found in CONDITIONS vector")
}

# --------------------------
# DESeq2 parameters
# --------------------------
PADJ_THRESHOLD <- 0.05
LOG2FC_THRESHOLD <- 1
MIN_COUNTS_FILTER <- 10

# Validate thresholds
if (PADJ_THRESHOLD <= 0 || PADJ_THRESHOLD >= 1) {
  stop("PADJ_THRESHOLD must be between 0 and 1")
}

if (LOG2FC_THRESHOLD < 0) {
  stop("LOG2FC_THRESHOLD must be non-negative")
}

if (MIN_COUNTS_FILTER < 0) {
  stop("MIN_COUNTS_FILTER must be non-negative")
}

# --------------------------
# Enrichment analysis
# --------------------------
GO_ONTOLOGY <- "BP"  # Options: "BP", "MF", "CC", "ALL"
PVAL_CUTOFF <- 0.05
QVAL_CUTOFF <- 0.05

# Validate GO ontology
valid_ontologies <- c("BP", "MF", "CC", "ALL")
if (!GO_ONTOLOGY %in% valid_ontologies) {
  stop("GO_ONTOLOGY must be one of: ", paste(valid_ontologies, collapse = ", "))
}

# --------------------------
# Organism database
# --------------------------
ORG_DB <- "org.Sc.sgd.db"
GENE_ID_TYPE <- "ORF"

# --------------------------
# Validation function
# --------------------------
validate_r_config <- function() {
  errors <- character()
  warnings <- character()
  
  # Check if required packages are installed
  required_packages <- c("DESeq2", "clusterProfiler", "org.Sc.sgd.db", 
                         "ggplot2", "pheatmap", "enrichplot")
  
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      errors <- c(errors, paste("Required package not installed:", pkg))
    }
  }
  
  # Check for analysis inputs (counts and metadata)
  if (file.exists(COUNTS_MATRIX_PATH) && file.exists(SAMPLE_METADATA_PATH)) {
    # Try loading to validate
    tryCatch({
      counts <- readRDS(COUNTS_MATRIX_PATH)
      metadata <- readRDS(SAMPLE_METADATA_PATH)
      
      # Validate dimensions
      if (ncol(counts) != nrow(metadata)) {
        errors <- c(errors, 
                    paste("Sample count mismatch:",
                          "count matrix has", ncol(counts), "samples,",
                          "metadata has", nrow(metadata), "samples"))
      }
      
      # Validate conditions
      if (length(CONDITIONS) != nrow(metadata)) {
        warnings <- c(warnings,
                      paste("CONDITIONS length (", length(CONDITIONS), 
                            ") doesn't match metadata rows (", nrow(metadata), ")", sep = ""))
      }
      
    }, error = function(e) {
      warnings <- c(warnings, 
                    paste("Could not validate data files:", e$message))
    })
  } else {
    warnings <- c(warnings, 
                  "Count matrix or metadata not found (will be created by pipeline)")
  }
  
  # Check directories
  if (!dir.exists(FEATURECOUNTS_DIR)) {
    warnings <- c(warnings, 
                  paste("featureCounts directory not found:", FEATURECOUNTS_DIR))
  }
  
  # Report errors
  if (length(errors) > 0) {
    message("ERROR: R configuration validation failed:")
    for (err in errors) {
      message("  ✗ ", err)
    }
    stop("Please fix configuration errors before running")
  }
  
  # Report warnings
  if (length(warnings) > 0) {
    message("WARNING: R configuration issues detected:")
    for (warn in warnings) {
      message("  ⚠ ", warn)
    }
  }
  
  # Success message
  message("✓ R configuration loaded and validated successfully")
  message("  Project root: ", PROJECT_ROOT)
  message("  Output directory: ", OUTPUT_DIR)
  message("  Samples: ", length(CONDITIONS))
  message("  Conditions: ", paste(unique(CONDITIONS), collapse = ", "))
  message("  Reference: ", REFERENCE_CONDITION)
  
  invisible(TRUE)
}

# --------------------------
# Auto-validate on source
# --------------------------
validate_r_config()

# --------------------------
# Create necessary directories
# --------------------------
dir.create(OUTPUT_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(PLOTS_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TABLES_DIR, showWarnings = FALSE, recursive = TRUE)

message("✓ Output directories ensured")
