#!/bin/bash
set -euo pipefail

SECONDS=0

# ======================
# Configuration
# ======================

source ./config.sh

# ======================
# Directory setup
# ======================
mkdir -p \
  "$FASTQC_PRE_DIR" \
  "$FASTQC_POST_DIR" \
  "$TRIMMED_FASTQ_DIR" \
  "$HISAT2_DIR" \
  "$FEATURECOUNTS_DIR" \
  "$LOG_DIR"

cd "$WORKDIR"

# ======================
# Pipeline
# ======================
for FASTQ_FILE in "$FASTQC_PRE_DIR"/*.fastq; do
    SAMPLE_NAME=$(basename "$FASTQ_FILE" .fastq)
    echo "Processing sample: $SAMPLE_NAME"

    # ----------------------
    # FastQC (raw reads)
    # ----------------------
    fastqc "$FASTQ_FILE" \
      -o "$FASTQC_PRE_DIR" \
      > "$LOG_DIR/fastqc_pre_${SAMPLE_NAME}.log" 2>&1

    # ----------------------
    # Trimming
    # ----------------------
    TRIMMED_FASTQ_FILE="$TRIMMED_FASTQ_DIR/${SAMPLE_NAME}_trimmed.fastq"

    java -jar "$TRIMMO_JAR" SE \
      -threads "$THREADS" \
      "$FASTQ_FILE" \
      "$TRIMMED_FASTQ_FILE" \
      ILLUMINACLIP:"$TRIMMOMATIC_ADAPTERS":2:30:10 \
      SLIDINGWINDOW:4:20 \
      TRAILING:10 \
      MINLEN:20 \
      -phred33

    if [ ! -s "$TRIMMED_FASTQ_FILE" ]; then
        echo "Error: Trimmomatic failed for $SAMPLE_NAME"
        exit 1
    fi

    # ----------------------
    # FastQC (trimmed reads)
    # ----------------------
    fastqc "$TRIMMED_FASTQ_FILE" \
      -o "$FASTQC_POST_DIR" \
      > "$LOG_DIR/fastqc_post_${SAMPLE_NAME}.log" 2>&1

    # ----------------------
    # HISAT2 alignment
    # ----------------------
    BAM_FILE="$HISAT2_DIR/${SAMPLE_NAME}_trimmed.bam"

    hisat2 -q \
      --rna-strandness R \
      -x "$HISAT2_INDEX" \
      -U "$TRIMMED_FASTQ_FILE" \
      | samtools sort -@ "$THREADS" -o "$BAM_FILE"

    echo "HISAT2 finished for $SAMPLE_NAME"

    # ----------------------
    # featureCounts
    # ----------------------
    FEATURECOUNTS_OUTPUT="$FEATURECOUNTS_DIR/${SAMPLE_NAME}_featurecounts.txt"

    featureCounts \
      -T "$THREADS" \
      -S 2 \
      -a "$GTF_FILE" \
      -o "$FEATURECOUNTS_OUTPUT" \
      "$BAM_FILE"

    cut -f1,7 "$FEATURECOUNTS_OUTPUT" | tail -n +2 \
      > "$OUTPUT_DIR/featurecounts/Counts_${SAMPLE_NAME}.txt"

    echo "featureCounts finished for $SAMPLE_NAME"
    echo "--------------------------------------"

done

# ======================
# Runtime summary
# ======================
duration=$SECONDS
echo "Total execution time: $((duration / 60)) minutes $((duration % 60)) seconds"
