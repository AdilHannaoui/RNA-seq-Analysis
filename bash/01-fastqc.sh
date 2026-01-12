#!/bin/bash
# Quality control using FastQC
# Author: Adil Hannaoui Anaaoui

WORKDIR="/mnt/c/Users/rna-seq/"                            
FASTQ_DIR="$WORKDIR/data/"                                 
OUTPUT_DIR="$WORKDIR/output"                                
THREADS=6                                                  


mkdir -p "$OUTPUT_DIR/fastqc_results"    
cd "$WORKDIR"                            

for FASTQ_FILE in "$FASTQ_DIR"/*.fastq; do
    SAMPLE_NAME=$(basename "$FASTQ_FILE" .fastq)
    echo "Procesando muestra: $SAMPLE_NAME"
    fastqc "$FASTQ_FILE" -o "$OUTPUT_DIR" > "$OUTPUT_DIR/$SAMPLE_NAME.log" 2>&1
done
