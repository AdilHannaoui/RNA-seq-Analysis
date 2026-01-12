# RNA-seq-Analysis

## Project overview
<p align="justify">
This repository contains a complete RNA-seq analysis pipeline applied to Saccharomyces cerevisiae strains carrying mutations in the Rpb4 subunit of RNA polymerase II.

The analysis covers:
* Quality control of raw FASTQ files
* Read alignment and quantification
* Differential expression analysis
* Downstream statistical analysis and visualization
</p>

## Experimental design

- Organism: Saccharomyces cerevisiae
- Conditions:
  - WT (n = 6)
  - Rpb4-S/T-A (n = 3)
  - Rpb4-S/T-D (n = 3)
- Data type: RNA-seq (Single End)

## Dataset
<p align="justify">
RNA-seq data were generated at the Institute of Functional Biology and Genomics (IBFG).
Due to data usage restrictions, raw sequencing files (FASTQ) cannot be publicly shared.

Gene-level count matrices and sample metadata are provided in this repository,
allowing full reproducibility of the downstream statistical analysis.
</p>
## RNA-seq pipeline

1. Quality control using FastQC
2. Adapter trimming and filtering
3. Alignment to the reference genome
4. Gene-level quantification
5. Differential expression analysis with DESeq2

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
bash/        RNA-seq preprocessing scripts  
R/           Statistical analysis scripts  
data/        Count matrix and sample metadata  
results/     Figures and tables  
