#!/bin/bash
# Purpose: Quantify gene expression from aligned RNA-seq BAM files using featureCounts.
# Produces both raw count tables and simplified count files for downstream analysis.
# Author: Adil Hannaoui Anaaoui

set -euo pipefail

WORKDIR="/mnt/c/Users/rna-seq"
OUTPUT_DIR="$WORKDIR/output"
FASTQ_DIR="$OUTPUT_DIR/fastq_trimmed"
GTF_FILE="$WORKDIR/HISAT2/cerevisiae/Saccharomyces_cerevisiae.R64-1-1.112.gtf"
THREADS=6

mkdir -p "$OUTPUT_DIR/featurecounts"
cd "$WORKDIR"

for FASTQ_FILE in "$FASTQ_DIR"/*.fastq; do
    SAMPLE_NAME=$(basename "$FASTQ_FILE" .fastq)
    echo "Processing Sample: $SAMPLE_NAME"

    BAM_FILE="$OUTPUT_DIR/hisat2/${SAMPLE_NAME}_trimmed.bam"
    FEATURECOUNTS_OUTPUT="$OUTPUT_DIR/featurecounts/${SAMPLE_NAME}_featurecounts.txt"

    # Run featureCounts
    if ! featureCounts -T "$THREADS" -S 2 -a "$GTF_FILE" -o "$FEATURECOUNTS_OUTPUT" "$BAM_FILE"; then
        echo "Error: featureCounts failed for $SAMPLE_NAME"
        continue
    fi

    # Extract only gene ID and counts
    cut -f1,7 "$FEATURECOUNTS_OUTPUT" | tail -n +2 > "$OUTPUT_DIR/featurecounts/Counts_${SAMPLE_NAME}.txt"
    echo "featureCounts finished for $SAMPLE_NAME!"
done

