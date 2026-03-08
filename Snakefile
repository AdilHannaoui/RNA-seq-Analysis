# =============================================================================
# Snakefile — RNA-seq Analysis Pipeline
# Author: Adil Hannaoui Anaaoui
#
# Pipeline:
#   FASTQ → FastQC (pre) → Trimmomatic + FastQC (post) → HISAT2 → featureCounts
#
# Usage:
#   snakemake --cores 8
#   snakemake --cores 8 --use-conda   # if using conda envs per rule
#   snakemake --dag | dot -Tsvg > dag.svg  # visualise DAG
# =============================================================================

import os
from pathlib import Path

# ── Configuration ─────────────────────────────────────────────────────────────
configfile: "config/config.yaml"

WORKDIR       = config["workdir"]
FASTQ_DIR     = config["fastq_dir"]
OUTPUT_DIR    = config["output_dir"]
HISAT2_INDEX  = config["hisat2_index"]
GTF_FILE      = config["gtf_file"]
TRIMMO_JAR    = config["trimmomatic_jar"]
ADAPTERS      = config["adapters"]
THREADS       = config["threads"]

# ── Samples ───────────────────────────────────────────────────────────────────
# Auto-detect samples from FASTQ directory
SAMPLES = [
    Path(f).stem
    for f in Path(FASTQ_DIR).glob("*.fastq")
]

if not SAMPLES:
    raise ValueError(f"No .fastq files found in {FASTQ_DIR}")

print(f"Samples detected ({len(SAMPLES)}): {sorted(SAMPLES)}")

# ── Target rule ───────────────────────────────────────────────────────────────
rule all:
    input:
        # FastQC pre-trimming
        expand(f"{OUTPUT_DIR}/fastqc_pre/{{sample}}_fastqc.html", sample=SAMPLES),
        # FastQC post-trimming
        expand(f"{OUTPUT_DIR}/fastqc_post/{{sample}}_trimmed_fastqc.html", sample=SAMPLES),
        # featureCounts final counts
        expand(f"{OUTPUT_DIR}/featurecounts/Counts_{{sample}}.txt", sample=SAMPLES),


# ── Rule 1: FastQC (pre-trimming) ─────────────────────────────────────────────
rule fastqc_pre:
    input:
        fastq = f"{FASTQ_DIR}/{{sample}}.fastq"
    output:
        html = f"{OUTPUT_DIR}/fastqc_pre/{{sample}}_fastqc.html",
        zip  = f"{OUTPUT_DIR}/fastqc_pre/{{sample}}_fastqc.zip"
    log:
        f"{OUTPUT_DIR}/logs/{{sample}}_fastqc_pre.log"
    threads: 1
    shell:
        """
        mkdir -p {OUTPUT_DIR}/fastqc_pre
        fastqc {input.fastq} \
            --threads {threads} \
            --outdir {OUTPUT_DIR}/fastqc_pre \
            > {log} 2>&1
        """


# ── Rule 2: Trimmomatic + FastQC post ─────────────────────────────────────────
rule trimming:
    input:
        fastq = f"{FASTQ_DIR}/{{sample}}.fastq"
    output:
        trimmed = f"{OUTPUT_DIR}/fastq_trimmed/{{sample}}_trimmed.fastq"
    log:
        f"{OUTPUT_DIR}/logs/{{sample}}_trimming.log"
    threads: 1
    shell:
        """
        mkdir -p {OUTPUT_DIR}/fastq_trimmed
        java -jar {TRIMMO_JAR} SE \
            -threads {threads} \
            {input.fastq} {output.trimmed} \
            ILLUMINACLIP:{ADAPTERS}:2:30:10 \
            SLIDINGWINDOW:4:20 \
            MINLEN:20 \
            -phred33 \
            > {log} 2>&1
        """

rule fastqc_post:
    input:
        trimmed = f"{OUTPUT_DIR}/fastq_trimmed/{{sample}}_trimmed.fastq"
    output:
        html = f"{OUTPUT_DIR}/fastqc_post/{{sample}}_trimmed_fastqc.html",
        zip  = f"{OUTPUT_DIR}/fastqc_post/{{sample}}_trimmed_fastqc.zip"
    log:
        f"{OUTPUT_DIR}/logs/{{sample}}_fastqc_post.log"
    threads: 1
    shell:
        """
        mkdir -p {OUTPUT_DIR}/fastqc_post
        fastqc {input.trimmed} \
            --threads {threads} \
            --outdir {OUTPUT_DIR}/fastqc_post \
            >> {log} 2>&1
        """


# ── Rule 3: HISAT2 alignment ──────────────────────────────────────────────────
rule hisat2:
    input:
        trimmed = f"{OUTPUT_DIR}/fastq_trimmed/{{sample}}_trimmed.fastq"
    output:
        bam = f"{OUTPUT_DIR}/hisat2/{{sample}}.bam"
    log:
        f"{OUTPUT_DIR}/logs/{{sample}}_hisat2.log"
    threads: 1
    shell:
        """
        mkdir -p {OUTPUT_DIR}/hisat2
        hisat2 \
            -q \
            --rna-strandness R \
            -p {threads} \
            -x {HISAT2_INDEX} \
            -U {input.trimmed} \
            2> {log} \
        | samtools sort -@ {threads} -o {output.bam}
        """


# ── Rule 4: featureCounts ─────────────────────────────────────────────────────
rule featurecounts:
    input:
        bam = f"{OUTPUT_DIR}/hisat2/{{sample}}.bam"
    output:
        full   = f"{OUTPUT_DIR}/featurecounts/{{sample}}_featurecounts.txt",
        counts = f"{OUTPUT_DIR}/featurecounts/Counts_{{sample}}.txt"
    log:
        f"{OUTPUT_DIR}/logs/{{sample}}_featurecounts.log"
    threads: 1
    shell:
        """
        mkdir -p {OUTPUT_DIR}/featurecounts
        featureCounts \
            -T {threads} \
            -S 2 \
            -a {GTF_FILE} \
            -o {output.full} \
            {input.bam} \
            > {log} 2>&1

        # Extract gene ID + counts only
        cut -f1,7 {output.full} | tail -n +2 > {output.counts}
        """
