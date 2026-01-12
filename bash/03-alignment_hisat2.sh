#!/bin/bash

# Purpose: Align trimmed RNA-seq reads to the Saccharomyces cerevisiae reference genome
# using HISAT2. The output are sorted BAM files suitable for quantification.

# Author: Adil Hannaoui Anaaoui

set -euo pipefail

WORKDIR="/mnt/c/Users/rna-seq"
HISAT2_INDEX="$WORKDIR/HISAT2/cerevisiae/index/genome"
GTF_FILE="$WORKDIR/HISAT2/cerevisiae/Saccharomyces_cerevisiae.R64-1-1.112.gtf"
OUTPUT_DIR="$WORKDIR/output"
FASTQ_DIR="$OUTPUT_DIR/fastq_trimmed"
THREADS=6

cd "$WORKDIR"
mkdir -p "$OUTPUT_DIR/hisat2"

for FASTQ_FILE in "$FASTQ_DIR"/*.fastq; do
    SAMPLE_NAME=$(basename "$FASTQ_FILE" .fastq)
    echo "Processing sample: $SAMPLE_NAME"

    BAM_FILE="$OUTPUT_DIR/hisat2/${SAMPLE_NAME}_trimmed.bam"

    # Run HISAT2 and sort BAM
    if ! hisat2 -q --rna-strandness R -p "$THREADS" -x "$HISAT2_INDEX" -U "$FASTQ_FILE" | \
        samtools sort -@ "$THREADS" -o "$BAM_FILE"; then
        echo "Error: HISAT2 or Samtools failed for $SAMPLE_NAME"
        continue
    fi

    echo "HISAT2 finished for $SAMPLE_NAME!"
done
