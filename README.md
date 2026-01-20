# RNA-seq-Analysis

## Project overview
<p align="justify">
This repository contains a complete RNA-seq analysis pipeline applied to Saccharomyces cerevisiae strains carrying mutations in the Rpb4 subunit of RNA polymerase II.

The analysis covers:
* Quality control of raw FASTQ files
* Read alignment and quantification
* Differential expression analysis
* Downstream statistical analysis and visualization

The objective of this project is to characterize transcriptional changes associated with phospho-null and phospho-mimetic mutations in the Rpb4 subunit.
</p>

## Experimental design

- Organism: Saccharomyces cerevisiae
- Conditions:
  - WT (n = 6)
  - Rpb4-S/T-A (n = 3)
  - Rpb4-S/T-D (n = 3)
- Data type: RNA-seq (Single End)

Biological replicates were used for all conditions.

## Dataset
<p align="justify">
RNA-seq data were generated at the Institute of Functional Biology and Genomics (IBFG).
Due to data usage restrictions, raw sequencing files (FASTQ) cannot be publicly shared.

Gene-level count matrices and sample metadata are provided in this repository,
allowing full reproducibility of the downstream statistical analysis.
</p>

## RNA-seq pipeline
The pipeline includes preprocessing, alignment, quantification, and differential expression analysis.

## Biologic Context

### About Saccharomyces cerevisiae
<p align="justify">
Saccharomyces cerevisiae is a unicellular eukaryotic fungus widely used as a model organism in molecular biology, genetics, and biotechnology. Its main advantages include a short life cycle, easy and inexpensive cultivation, a fully sequenced genome, and an extensive collection of genetic tools (mutant libraries, ORF collections, tagging systems, and genome‑editing methods). These features enable high‑throughput experiments and mechanistic studies of cellular processes that are conserved in higher eukaryotes, such as transcription, RNA processing, translation, and stress responses.
</p>

### Rpb4-subunit Role
<p align="justify">
  
**Rpb4** is one of the key subunits of RNA polymerase II (Pol II) and plays an essential role in processes such as transcription complex recruitment, RNA elongation, and the coupling between nuclear and cytoplasmic events related to mRNA metabolism. Together with Rpb7, it forms a stable subcomplex that associates with Pol II and contributes both to its regulatory functions and to the structural integrity of the enzyme.

Recent studies have identified several phosphorylatable residues in Rpb4 —S125, S197, T134, T144, and T193— suggesting that phosphorylation may represent an important regulatory mechanism for its activity. Modification of these residues could influence Rpb4 function and, consequently, the overall performance and regulation of RNA polymerase II.
</p>

### Project Context
<p align="justify">
This project, carried out at the Institute of Functional Biology and Genomics (IBFG), aims to study and characterize the Rpb4 subunit of RNA polymerase II under different mutagenic conditions. To achieve this, two strains were generated through site‑directed mutagenesis, specifically designed to alter the phosphorylatable residues of the protein:

* Rpb4‑S/T‑A: the five phosphorylatable residues identified in Rpb4 are replaced with alanine, thereby eliminating any potential phosphorylation or regulatory interaction mediated by these sites.

* Rpb4‑S/T‑D: the same five residues are replaced with aspartate, introducing a negative charge that mimics the phosphorylated state of serine and threonine residues.

The purpose of these constructs is to determine the functional role of these residues in Rpb4 activity and, consequently, in the proper performance of RNA polymerase II, assessing how phosphorylation (or its absence) influences key transcriptional processes.
</p>

## Repository structure

```text
bash/        RNA-seq preprocessing scripts (separated modules and complete pipeline)
R/           Statistical analysis scripts  
data/        Count matrix and sample metadata  
results/     Figures and tables  
```
## Methods
All analyses were performed using FastQC v0.11.9, Trimmomatic v0.39, HISAT2 v2.2.1, featureCounts v2.0, and R v4.4.0 The pipeline was executed on a Linux environment.

### FastQC and Trimmomatic
<p align="justify">
Quality control of the FASTQ files was performed using FastQC, followed by a trimming process with Trimmomatic according to the following criteria:

* ILLUMINACLIP:2:30:10: Removal of Illumina adapter sequences.

* SLIDINGWINDOW:4:20: Quality-based trimming using a 4-base sliding window with an average Phred quality threshold of 20 (99% base-call accuracy).

* MINLEN:20: Length-based filtering to discard processed reads shorter than 20 bases. This threshold facilitates a broad exploratory analysis by prioritizing sensitivity in transcript detection.
</p>

### HISAT2 Alignment
Sequence alignment was performed using HISAT2, a splice-aware aligner specifically designed for RNA-seq analysis. Since the libraries were prepared using the Illumina TruSeq Stranded protocol, the resulting reads originate from the reverse strand. Consequently, the ```--rna-strandness R``` option was applied to account for the strandedness of the sequencing data.


### FeatureCounts
Finally, the featureCounts tool was utilized to generate a gene count matrix for all samples in this study. This step is critical for the subsequent differential expression analysis using DESeq2. The ```-S 2``` option was specified to remain consistent with the reverse-stranded protocol employed during sequencing. The resulting file was saved in the ```/data``` directory of this repository.


### DESeq2 analysis
Differential expression was assessed using the DESeq2 package. This allows us to compare gene expression across the experimental conditions included in this study.

## Results
### MA plot
[![Figure 1 — MA plot](Plots/MA_WT_vs_A_thumb.png)](Plots/MA_WT_vs_A.pdf)
**Caption:** MA plot (WT vs A). Most genes centered at log2FC ≈ 0; highlighted genes meet padj < 0.05.
