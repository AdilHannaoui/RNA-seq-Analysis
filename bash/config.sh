#!/bin/bash

# ==================================================
# Global configuration file for RNA-seq pipeline
# ==================================================

# ----------------------
# Project directories
# ----------------------
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="$WORKDIR/output"
FASTQ_DIR="$WORKDIR/data"
BAM_DIR="$OUTPUT_DIR/hisat2"


# ----------------------
# Computational resources
# ----------------------
THREADS=8

# ----------------------
# Tools and references
# ----------------------

# Trimmomatic
TRIMMO_JAR="$CONDA_PREFIX/share/trimmomatic/trimmomatic.jar"
ADAPTERS="$CONDA_PREFIX/share/trimmomatic/adapters/TruSeq3-SE.fa"

# HISAT2
HISAT2_INDEX="$WORKDIR/HISAT2/cerevisiae/index/genome"

# Gene annotation
GTF_FILE="$WORKDIR/HISAT2/cerevisiae/Saccharomyces_cerevisiae.R64-1-1.112.gtf"

# ----------------------
# Output subdirectories
# ----------------------
FASTQC_PRE_DIR="$OUTPUT_DIR/fastqc_pre"
FASTQC_POST_DIR="$OUTPUT_DIR/fastqc_post"
FASTQ_TRIM="$OUTPUT_DIR/fastq_trimmed"
HISAT2_DIR="$OUTPUT_DIR/hisat2"
FEATURECOUNTS_DIR="$OUTPUT_DIR/featurecounts"
LOG_DIR="$OUTPUT_DIR/logs"
