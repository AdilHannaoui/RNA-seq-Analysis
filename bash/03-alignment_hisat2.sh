#!/usr/bin/env bash
set -euo pipefail

# ==========================
# HISAT2 Alignment Module (parallel + pigz)
# Author: Adil Hannaoui Anaaoui
# ==========================
# Load global config
source "$(dirname "$0")/../config.sh"

mkdir -p "$OUTPUT_DIR/hisat2"
mkdir -p "$OUTPUT_DIR/logs"

cd "$WORKDIR"

# --------------------------
# Detect FASTQ files (.fastq or .fastq.gz)
# --------------------------
FASTQ_FILES=($(ls "$FASTQ_TRIM"/*.fastq "$FASTQ_TRIM"/*.fastq.gz 2>/dev/null || true))

if [[ ${#FASTQ_FILES[@]} -eq 0 ]]; then
    echo "No FASTQ files found in $FASTQ_TRIM"
    exit 1
fi

echo "Found ${#FASTQ_FILES[@]} FASTQ files."

# --------------------------
# Optional: decompress gz files using pigz
# --------------------------
echo "Checking for compressed FASTQ files..."

for f in "${FASTQ_FILES[@]}"; do
    if [[ "$f" == *.gz ]]; then
        echo "Decompressing $f using pigz..."
        pigz -d -p "$THREADS" "$f"
    fi
done

# Refresh list after decompression
FASTQ_FILES=($(ls "$FASTQ_TRIM"/*.fastq))

# --------------------------
# Function to run HISAT2 + samtools sort
# --------------------------
run_hisat2() {
    FASTQ_FILE="$1"
    SAMPLE_NAME=$(basename "$FASTQ_FILE" .fastq)

    BAM_FILE="$OUTPUT_DIR/hisat2/${SAMPLE_NAME}.bam"
    LOGFILE="$OUTPUT_DIR/logs/${SAMPLE_NAME}_hisat2.log"

    echo ">>> Aligning $SAMPLE_NAME"

    # HISAT2 + sort
    hisat2 \
        -q \
        --rna-strandness R \
        -p 1 \
        -x "$HISAT2_INDEX" \
        -U "$FASTQ_FILE" \
        2> "$LOGFILE" \
    | samtools sort -@ 1 -o "$BAM_FILE" >> "$LOGFILE" 2>&1

    if [[ ! -s "$BAM_FILE" ]]; then
        echo "ERROR: HISAT2 failed for $SAMPLE_NAME" >&2
        exit 1
    fi

    echo ">>> Finished $SAMPLE_NAME"
}

export -f run_hisat2
export HISAT2_INDEX OUTPUT_DIR

# --------------------------
# Run HISAT2 in parallel
# --------------------------
echo "Running HISAT2 in parallel using $THREADS threads..."

parallel -j "$THREADS" run_hisat2 ::: "${FASTQ_FILES[@]}"

echo "All HISAT2 alignments completed."
echo "BAM files saved in: $OUTPUT_DIR/hisat2"
echo "Logs saved in: $OUTPUT_DIR/logs"
