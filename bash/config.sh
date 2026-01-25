#!/bin/bash

# ==================================================
# Global configuration file for RNA-seq pipeline
# ==================================================

# ----------------------
# Project directories
# ----------------------
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$WORKDIR/output"
FASTQ_DIR="$OUTPUT_DIR/fastq_trimmed"
HISAT2_INDEX="$WORKDIR/HISAT2/cerevisiae/index/genome"
GTF_FILE="$WORKDIR/HISAT2/cerevisiae/Saccharomyces_cerevisiae.R64-1-1.112.gtf"
BAM_DIR="$OUTPUT_DIR/hisat2"
TRIMMO_JAR="$WORKDIR/Trimmomatic-0.39/trimmomatic-0.39.jar"
ADAPTERS="$WORKDIR/Trimmomatic-0.39/adapters/TruSeq3-SE.fa"


# ----------------------
# Computational resources
# ----------------------
THREADS=8

# ----------------------
# Tools and references
# ----------------------

# Trimmomatic
TRIMMO_JAR="$WORKDIR/Trimmomatic-0.39/trimmomatic-0.39.jar"
TRIMMOMATIC_ADAPTERS="$WORKDIR/Trimmomatic-0.39/adapters/TruSeq3-SE.fa"

# HISAT2
HISAT2_INDEX="$WORKDIR/HISAT2/cerevisiae/index/genome"

# Gene annotation
GTF_FILE="$WORKDIR/HISAT2/cerevisiae/Saccharomyces_cerevisiae.R64-1-1.112.gtf"

# ----------------------
# Output subdirectories
# ----------------------
FASTQC_PRE_DIR="$OUTPUT_DIR/fastqc_pre"
FASTQC_POST_DIR="$OUTPUT_DIR/fastqc_post"
TRIMMED_FASTQ_DIR="$OUTPUT_DIR/fastq_trimmed"
HISAT2_DIR="$OUTPUT_DIR/hisat2"
FEATURECOUNTS_DIR="$OUTPUT_DIR/featurecounts"
LOG_DIR="$OUTPUT_DIR/logs"
