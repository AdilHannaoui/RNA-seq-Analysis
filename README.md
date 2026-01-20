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
### PCA
<p float="left">
  <img src="Plots/PCA_all_samples.png" width="70%"
</p>

<p align="justify">
El análisis de componentes principales muestra una separación clara entre las tres condiciones transcriptómicas: tipo silvestre, mutante fosfo-nulo (S/T-A) y mutante fosfomimético (S/T-D). La mayor fuente de variación (PC1) distingue al WT de los mutantes, mientras que la segunda componente (PC2) separa los dos tipos de mutación, indicando que sus efectos sobre la expresión génica son distintos. Estos resultados confirman que la fosforilación de Rpb4 tiene un impacto global sobre el transcriptoma y que su alteración genera perfiles específicos según el tipo de sustitución.
</p>

### MA plot
<p float="left">
  <img src="Plots/MA_WT_vs_A.png" width="45%" />
  <img src="Plots/MA_WT_vs_D.png" width="45%" />
</p>

<p align="justify">
The transcriptomic comparisons between the mutant strains and the wild type show that altering the phosphorylatable residues of Rpb4 has a clear impact on gene expression. Both variants, the phospho-null and the phosphomimetic, display deviations from the WT pattern, indicating that Rpb4 phosphorylation participates in the normal regulation of the transcriptome. The S/T-A strain exhibits broader and more dispersed changes, consistent with a complete loss of phosphorylation-dependent regulation, whereas the S/T-D strain shows a more moderate profile, compatible with a partial mimicry of the phosphorylated state. Taken together, these results suggest that the ability of Rpb4 to be phosphorylated contributes to its regulatory function, although a deeper functional analysis will be necessary to determine which pathways or cellular processes are specifically affected.
</p>

### Volcano plot
<p float="left">
  <img src="Plots/Volcano_WT_vs_A.png" width="45%" />
  <img src="Plots/Volcano_WT_vs_D.png" width="45%" />
</p>

<p align="justify">
The volcano plots confirm that mutations in the phosphorylatable residues of Rpb4 induce statistically significant changes in gene expression compared to the wild type. The phospho-null strain (S/T-A) displays a larger number of differentially expressed genes, with a more pronounced range of regulatory changes, suggesting a deeper deregulation of the transcriptome. In contrast, the phosphomimetic strain (S/T-D) shows a more conserved profile, consistent with a partial preservation of Rpb4’s regulatory function. These results reinforce the idea that Rpb4 phosphorylation is necessary to maintain proper control of gene expression, although they do not yet allow the identification of which cellular processes are affected without further functional analysis.
</p>

### Heatmap
<p float="left">
  <img src="Plots/Heatmap_top50_WT_vs_conditions.png" width="70%" 
</p>

<p align="justify">
This heatmap shows the 50 most significantly regulated genes in the WT vs Rpb4-S/T-A comparison, visualized across all experimental conditions. A clear separation is observed between the transcriptomic profiles of WT, Alanine, and Aspartate, confirming that mutations in the phosphorylatable residues of Rpb4 produce reproducible and specific effects on gene expression. The phospho-null strain exhibits a more pronounced deregulation, whereas the phosphomimetic strain partially preserves the wild-type pattern. These results reinforce the functional involvement of Rpb4 phosphorylation in the coordinated regulation of gene programs and justify further functional analysis to identify the affected pathways.
</p>

### Enrichment Analysis
<p float="left">
  <img src="Plots/GO_WT_vs_A.png" width="45%" />
  <img src="Plots/GO_WT_vs_D.png" width="45%" />
</p>

<p align="justify">
Functional enrichment analyses reveal that the phospho-null Rpb4-S/T-A mutation induces a significant deregulation of metabolic pathways, with a marked downregulation of processes related to nucleotide biosynthesis (particularly purines and IMP) and an upregulation of pathways associated with amino acid metabolism, such as arginine and glutamine. In contrast, the phosphomimetic Rpb4-S/T-D mutation affects reproductive and organic acid biosynthetic processes, while activating pathways involved in amino acid catabolism and protein folding. These results indicate that Rpb4 phosphorylation selectively modulates metabolic and cellular stress programs, with distinct effects depending on the type of substitution.
</p>

## Conclusions
<p align="justify">
The set of transcriptomic analyses demonstrates that Rpb4 phosphorylation plays a functionally relevant role in gene regulation. The PCA shows a clear separation among the three conditions, indicating that the phospho-null (S/T-A) and phosphomimetic (S/T-D) mutations generate distinct and reproducible transcriptomic profiles. The MA and volcano plots confirm that both mutations induce significant changes in gene expression, with more pronounced effects in the S/T-A strain. The heatmap of the most regulated genes reinforces this difference, showing coordinated deregulation in the Alanine mutant and a more conserved pattern in Aspartate. Finally, GO analyses reveal that these mutations alter specific metabolic pathways, affecting nucleotide biosynthesis, amino acid metabolism, reproduction, and protein stress response processes. Altogether, the data indicate that Rpb4’s ability to be phosphorylated is essential for maintaining the cell’s transcriptomic and functional homeostasis.
</p>
