#!/usr/bin/env bash

set -e
set -o pipefail

SECONDS=0
echo "=== Pipeline started successfully ===)"

# 1. Environment Activation
echo "[1/7] Activating Conda environment..."
source ~/miniconda3/etc/profile.d/conda.sh
conda activate rnaseq-rpb4

# 2. Configuration loading
echo "[2/7] Loading R config..."
CONFIG_R="R/config.R"
echo "[2/7] Loading bash config..."
CONFIG_bash="bash/config.sh"


# 3. QC
echo "[3/7] Running FastQC..."
bash bash/01-fastqc.sh $CONFIG_bash

# 4. Trimming
echo "[4/7] Running Trimmomatic..."
bash bash/02-trimming.sh $CONFIG_bash

# 5. Alineamiento
echo "[5/7] Running HISAT2..."
bash bash/03-alignment.sh $CONFIG_bash

# 6. Counts
echo "[6/7] Running featureCounts..."
bash bash/04-featurecounts.sh $CONFIG_bash

# 7. R Analysis
echo "[7/7] Running DESeq2 and downstream analysis..."
Rscript R/01-deseq2_analysis.R $CONFIG_R
Rscript R/02-visualizations.R $CONFIG_R
Rscript R/03-enrichment.R $CONFIG_R

duration=$SECONDS
echo "Total execution time: $((duration / 60)) minutes $((duration % 60)) seconds"
