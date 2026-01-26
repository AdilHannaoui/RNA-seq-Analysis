#!/usr/bin/env bash
set -euo pipefail

# ==========================
# Trimmomatic QC + Adapter Removal (parallel + pigz)
# Author: Adil Hannaoui Anaaoui
# ==========================
# Load global config
source "$(dirname "$0")/../config.sh"

mkdir -p "$OUTPUT_DIR/fastq_trimmed"
mkdir -p "$OUTPUT_DIR/fastqc_trimmed"
mkdir -p "$OUTPUT_DIR/logs"

cd "$WORKDIR"

# --------------------------
# Detect FASTQ files (.fastq or .fastq.gz)
# --------------------------
FASTQ_FILES=($(ls "$FASTQ_DIR"/*.fastq "$FASTQ_DIR"/*.fastq.gz 2>/dev/null || true))

if [[ ${#FASTQ_FILES[@]} -eq 0 ]]; then
    echo "No FASTQ files found in $FASTQ_DIR"
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
FASTQ_FILES=($(ls "$FASTQ_DIR"/*.fastq))

# --------------------------
# Function to run Trimmomatic + FastQC
# --------------------------
run_trim() {
    FASTQ_FILE="$1"
    SAMPLE_NAME=$(basename "$FASTQ_FILE" .fastq)

    TRIMMED_FASTQ="$OUTPUT_DIR/fastq_trimmed/${SAMPLE_NAME}_trimmed.fastq"
    LOGFILE="$OUTPUT_DIR/logs/${SAMPLE_NAME}_trim.log"

    echo ">>> Trimming $SAMPLE_NAME"

    java -jar "$TRIMMO_JAR" SE \
        -threads 1 \
        "$FASTQ_FILE" "$TRIMMED_FASTQ" \
        ILLUMINACLIP:"$ADAPTERS:2:30:10" \
        SLIDINGWINDOW:4:20 \
        MINLEN:20 \
        -phred33 \
        > "$LOGFILE" 2>&1

    if [[ ! -s "$TRIMMED_FASTQ" ]]; then
        echo "ERROR: Trimmomatic failed for $SAMPLE_NAME" >&2
        exit 1
    fi

    echo ">>> Running FastQC on trimmed file: $SAMPLE_NAME"

    fastqc "$TRIMMED_FASTQ" \
        --threads 1 \
        --outdir "$OUTPUT_DIR/fastqc_trimmed" \
        >> "$LOGFILE" 2>&1

    echo ">>> Finished $SAMPLE_NAME"
}

export -f run_trim
export TRIMMO_JAR ADAPTERS OUTPUT_DIR

# --------------------------
# Run trimming in parallel
# --------------------------
echo "Running Trimmomatic in parallel using $THREADS threads..."

parallel -j "$THREADS" run_trim ::: "${FASTQ_FILES[@]}"

echo "All trimming + FastQC completed."
echo "Trimmed FASTQ files: $OUTPUT_DIR/fastq_trimmed"
echo "FastQC reports: $OUTPUT_DIR/fastqc_trimmed"
echo "Logs: $OUTPUT_DIR/logs"

