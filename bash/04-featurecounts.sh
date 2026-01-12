#!/bin/bash

# Purpose:

# Author: Adil Hannaoui Anaaoui

set -euo pipefail

WORKDIR="/mnt/c/Users/rna-seq"
FASTQ_DIR="$WORKDIR/data/"
OUTPUT_DIR="$WORKDIR/output/"
THREADS=6

cd "$WORKDIR"

for FASTQ_FILE in $FASTQ_DIR/*.fastq; do
	  SAMPLE_NAME=$(basename $FASTQ_FILE .fastq)

	  echo "Processing Sample: $SAMPLE_NAME"

    BAM_FILE=$OUTPUT_DIR/hisat2/${SAMPLE_NAME}_trimmed.bam
    FEATURECOUNTS_OUTPUT="$OUTPUT_DIR/featurecounts/${SAMPLE_NAME}_featurecounts.txt"
	  featureCounts -T $THREADS -S 2 -a $GTF_FILE -o $FEATURECOUNTS_OUTPUT $BAM_FILE

	# Control de errores featureCounts
	if [ $? -ne 0 ]; then
	    echo "Error: featureCounts no se ejecutó correctamente para $SAMPLE_NAME."
	    exit 1
	fi

	# Extraer conteos
	cut -f1,7 $FEATURECOUNTS_OUTPUT | tail -n +2 > $OUTPUT_DIR/featurecounts/Counts_${SAMPLE_NAME}.txt
	echo "featureCounts finalizado para $SAMPLE_NAME!"

done
