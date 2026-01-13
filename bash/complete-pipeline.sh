#!/bin/bash
set -euo pipefail

SECONDS=0

# ======================
# Configuration
# ======================
WORKDIR="/mnt/c/Users/rna-seq"
FASTQ_DIR="$WORKDIR/data"
TRIMMO_JAR="$WORKDIR/Trimmomatic-0.39/trimmomatic-0.39.jar"
HISAT2_INDEX="$WORKDIR/HISAT2/cerevisiae/index/genome"
GTF_FILE="$WORKDIR/HISAT2/cerevisiae/Saccharomyces_cerevisiae.R64-1-1.112.gtf"
OUTPUT_DIR="$WORKDIR/output"
THREADS=6

# ======================
# Directory setup
# ======================
mkdir -p \
  "$OUTPUT_DIR/fastqc_pre" \
  "$OUTPUT_DIR/fastqc_post" \
  "$OUTPUT_DIR/fastq_trimmed" \
  "$OUTPUT_DIR/hisat2" \
  "$OUTPUT_DIR/featurecounts" \
  "$OUTPUT_DIR/logs"

cd "$WORKDIR"

# ======================
# Pipeline
# ======================
for FASTQ_FILE in "$FASTQ_DIR"/*.fastq; do
    SAMPLE_NAME=$(basename "$FASTQ_FILE" .fastq)
    echo "Processing sample: $SAMPLE_NAME"

    # ----------------------
    # FastQC (raw reads)
    # ----------------------
    fastqc "$FASTQ_FILE" \
      -o "$OUTPUT_DIR/fastqc_pre" \
      > "$OUTPUT_DIR/logs/fastqc_pre_${SAMPLE_NAME}.log" 2>&1

    # ----------------------
    # Trimming
    # ----------------------
    TRIMMED_FASTQ_FILE="$OUTPUT_DIR/fastq_trimmed/${SAMPLE_NAME}_trimmed.fastq"

    java -jar "$TRIMMO_JAR" SE \
      -threads "$THREADS" \
      "$FASTQ_FILE" \
      "$TRIMMED_FASTQ_FILE" \
      ILLUMINACLIP:"$WORKDIR/Trimmomatic-0.39/adapters/TruSeq3-SE.fa":2:30:10 \
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
      -o "$OUTPUT_DIR/fastqc_post" \
      > "$OUTPUT_DIR/logs/fastqc_post_${SAMPLE_NAME}.log" 2>&1

    # ----------------------
    # HISAT2 alignment
    # ----------------------
    BAM_FILE="$OUTPUT_DIR/hisat2/${SAMPLE_NAME}_trimmed.bam"

    hisat2 -q \
      --rna-strandness R \
      -x "$HISAT2_INDEX" \
      -U "$TRIMMED_FASTQ_FILE" \
      | samtools sort -@ "$THREADS" -o "$BAM_FILE"

    echo "HISAT2 finished for $SAMPLE_NAME"

    # ----------------------
    # featureCounts
    # ----------------------
    FEATURECOUNTS_OUTPUT="$OUTPUT_DIR/featurecounts/${SAMPLE_NAME}_featurecounts.txt"

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
