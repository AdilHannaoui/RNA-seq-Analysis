#!/usr/bin/env bash

# ==================================================
# Global configuration file for RNA-seq pipeline
# Author: Adil Hannaoui Anaaoui
# ==================================================

# Validate that this script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "ERROR: This script must be sourced, not executed directly" >&2
    echo "Usage: source bash/config.sh" >&2
    exit 1
fi

# ----------------------
# Project directories
# ----------------------
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export WORKDIR

OUTPUT_DIR="$WORKDIR/output"
FASTQ_DIR="$WORKDIR/data"
BAM_DIR="$OUTPUT_DIR/hisat2"

export OUTPUT_DIR FASTQ_DIR BAM_DIR

# ----------------------
# Computational resources
# ----------------------
THREADS=8
export THREADS

# ----------------------
# Tools and references
# ----------------------
# Trimmomatic
TRIMMO_JAR="${CONDA_PREFIX}/share/trimmomatic/trimmomatic.jar"
ADAPTERS="${CONDA_PREFIX}/share/trimmomatic/adapters/TruSeq3-SE.fa"

# HISAT2
HISAT2_INDEX="$WORKDIR/HISAT2/cerevisiae/index/genome"

# Gene annotation
GTF_FILE="$WORKDIR/HISAT2/cerevisiae/Saccharomyces_cerevisiae.R64-1-1.112.gtf"

export TRIMMO_JAR ADAPTERS HISAT2_INDEX GTF_FILE

# ----------------------
# Output subdirectories
# ----------------------
FASTQC_PRE_DIR="$OUTPUT_DIR/fastqc_pre"
FASTQC_POST_DIR="$OUTPUT_DIR/fastqc_post"
FASTQ_TRIM="$OUTPUT_DIR/fastq_trimmed"
HISAT2_DIR="$OUTPUT_DIR/hisat2"
FEATURECOUNTS_DIR="$OUTPUT_DIR/featurecounts"
LOG_DIR="$OUTPUT_DIR/logs"

export FASTQC_PRE_DIR FASTQC_POST_DIR FASTQ_TRIM HISAT2_DIR FEATURECOUNTS_DIR LOG_DIR

# ----------------------
# Validation function
# ----------------------
_validate_bash_config() {
    local errors=()
    local warnings=()
    
    # Check conda environment
    if [[ -z "$CONDA_PREFIX" ]]; then
        errors+=("CONDA_PREFIX not set. Conda environment not activated?")
    fi
    
    # Check critical files
    if [[ ! -f "$TRIMMO_JAR" ]]; then
        errors+=("Trimmomatic JAR not found: $TRIMMO_JAR")
    fi
    
    if [[ ! -f "$ADAPTERS" ]]; then
        errors+=("Adapter file not found: $ADAPTERS")
    fi
    
    if [[ ! -f "$GTF_FILE" ]]; then
        errors+=("GTF file not found: $GTF_FILE")
    fi
    
    if [[ ! -f "${HISAT2_INDEX}.1.ht2" ]]; then
        errors+=("HISAT2 index not found: $HISAT2_INDEX (looking for ${HISAT2_INDEX}.1.ht2)")
    fi
    
    # Check input directory
    if [[ ! -d "$FASTQ_DIR" ]]; then
        warnings+=("FASTQ directory does not exist: $FASTQ_DIR")
    fi
    
    # Check for FASTQ files
    if [[ -d "$FASTQ_DIR" ]]; then
        local fastq_count=$(find "$FASTQ_DIR" -maxdepth 1 -type f \( -name "*.fastq" -o -name "*.fastq.gz" \) 2>/dev/null | wc -l)
        if [[ $fastq_count -eq 0 ]]; then
            warnings+=("No FASTQ files found in $FASTQ_DIR")
        fi
    fi
    
    # Report errors
    if [[ ${#errors[@]} -gt 0 ]]; then
        echo "ERROR: Configuration validation failed:" >&2
        printf '  ✗ %s\n' "${errors[@]}" >&2
        return 1
    fi
    
    # Report warnings
    if [[ ${#warnings[@]} -gt 0 ]]; then
        echo "WARNING: Configuration issues detected:" >&2
        printf '  ⚠ %s\n' "${warnings[@]}" >&2
    fi
    
    # Success message
    echo "✓ Configuration loaded and validated successfully"
    echo "  Working directory: $WORKDIR"
    echo "  Output directory: $OUTPUT_DIR"
    echo "  Threads: $THREADS"
    echo "  Conda environment: ${CONDA_DEFAULT_ENV:-unknown}"
    
    return 0
}

# ----------------------
# Auto-validate on source
# ----------------------
if ! _validate_bash_config; then
    echo "ERROR: Please fix configuration errors before running the pipeline" >&2
    return 1
fi
