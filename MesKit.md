---
title: 'Meskit : Analyze Whole exome sequencing (WES) data of multiple tumor samples'
output:
---


# Introduction

Tumor heterogeneity, as one of the characteristics of malignant tumors, often makes tumors' daughter cells exhibit molecular biological or genetic changes, thereby making differences in tumor features.
Therefore, understanding more about tumor heterogeneity could help us know more about how tumors develop and the structure of spatial cloning. 
Thus, more precise and accurate methods of tumor typing and treatments may be put forward. 
Currently, multi-site sampling is often used to evaluate the heterogeneity of tumors in the same patient.  
This package intends to analyze Whole exome sequencing (WES) data of multiple tumor samples.
Meskit could summarize, visualize, evaluate the information contained in MAF files, and do functional and clonal analysis.
Further analysis is also available, you could get the results of the development process of tumor and mutational signature analysis outcome.


# Installation

Install the latest version of this package by entering the following in R:

```r
install.packages("remotes")
```

```
## Installing package into 'C:/Users/HP-1/Documents/R/win-library/3.5'
## (as 'lib' is unspecified)
```

```
## package 'remotes' successfully unpacked and MD5 sums checked
## 
## The downloaded binary packages are in
## 	C:\Users\HP-1\AppData\Local\Temp\RtmpGKgAzn\downloaded_packages
```

```r
remotes::install_github("Niinleslie/MesKit")
```

```
## Skipping install of 'Meskit' from a github remote, the SHA1 (c2afa04f) has not changed since last install.
##   Use `force = TRUE` to force installation
```

# Brief process
## Prepare input files
To analyse with our packages you need to provide a set of input files, including:
  * Necessary details of samples;
  * Mutation information (MAF files);
  * Output files of Pyclone analysis (ccf files).

Here we give examples of details of samples and MAF files. And others you should prepare contain the output tables of Pyclone analysis (```clusters.tsv``` and ```loci.tsv``` for cluster and locus specific information).
 
### Information of samples
> It should contain the sampleID, patientID, lesion and time. Example data:
 
 |  sample  |  patient |  lesion |  time  |
 ---- | ------ | ------ | ------
 | 311252-S | 311252 |  S      |   -   |
 | 311252-V |  311252  |  V  |     -   |
 |311252-TC1 | 311252 |  TC  |     -   |
 |311252-TC2 | 311252 |  TC  |     -   |

### The MAF files
MAF files contain many fields of information about chromosome and gene mutations and their annotations. The following fields are highly recommended to be contained in the MAF files.

Hugo_Symbol, Chromosome, Start_Position, End_Position, Variant_Classification, Variant_Type, Reference_Allele,	Tumor_Seq_Allele1, Tumor_Seq_Allele2,	Ref_allele_depth,	Alt_allele_depth,	VAF, CDS_Change, Protein_Change,Tumor_Sample_Barcode.

Example MAF file:

| Hugo_Symbol|	Chromosome | Start_Position |	End_Position |	Variant_Classification | Variant_Type |	Reference_Allele |	Tumor_Seq_Allele1 | Tumor_Seq_Allele2 |	Ref_allele_depth |	Alt_allele_depth |	VAF	| CDS_Change	| Protein_Change |	Tumor_Sample_Barcode |
|:-----| :------| :------ | :----- | :------ | :----- | :---- | :-----| :----- | :----- | :-------| :---- | :-----| :----- | :----- |
| LOC729737| 1 | 135207 |	135207	| RNA |	SNP |	C | C |	G |	40	| 4 | 0.0909 | NA |	NA | 311252-S |
|TTC34,ACTRT2| 1 | 2869474 | 2869474 |	IGR |INS | - | | CTCTCT |	43 | 8 | 0.1568 | NA |	NA | 311252-S |
|NBPF1|1 | 16908223 |	16908223 | Intron | SNP | T |	T |A|	142| 8 | 0.0533 | NA| NA | 311252-S|
|PRAMEF2 | 1 | 12921600 | 12921600 | Missense_Mutation | SNP | C |	C | T |73 |	3 |	0.0394 | c.C1391T |	p.P464L | 311252-S |

## From MAF objects to Maf objects

`read.maf` function reads input MAF files, collects and summarizes data in them. Then returns a Maf object/class, which includes information of sample_info, mut.id and a summary figure of it.  

## ITH evaluation and Clonal analysis

A Maf object could be integrally or partly input into many functions in Meskit, which includes ITH evaluation and Clonal analysis. You can choose among them depend on your needs. 

  * The former filed contains functions of calculating MATH score, drawing variant allele frequency (VAF) distribution curve and getting the shared or private matations in different samples of the same patient.
  * Functions in the latter field can offer radar plots about tumor cloning,     and fishplots showing timeline of the tumor clonal evolution. 

## From Maf files to NJtree files

`read.njtree` function is able to creat a cancer phylogenetic tree by calculating and determining branches and trunks.
`Mutational_sigs_tree` function could get mutational signature for each branch of phylogenetic tree. Eventually, `NJtree` function would use information above, process Maf objects and return NJtree objects. 

## Functional analysis and NJtree plot 

We can do Go analysis and Pathway analysis with a NJtree object.Also can get phylogenetic tree and heatmap using `plotPhyloTree`function.

# Parameters

  * `patientID`: the numeric number of the selected patient
  * `maf` or `maf_file`: a Maf object return from `read.Maf`
  * `mat.nj`: a nj tree object generated from ape
  * `njtree`: a njtree object generated by NJtree.R
  
   
# Visualization
## MATH score
According to published researches, using MATH score to quantify tumor heterogeneity has certain clinical significance.
We can calculate MATH score through VAF of samples and present the results. Parameter `tsb` is set to select samples.

`MATH_score(maf_file, tsb = c("tsb1"))`


## VAF plot
This function produces density distribution plot, which can show you the clusters of muatations with different Variant Allele Frequencies in all/selected samples. 
Sample(s), and whether to show MATH score can be determined by controlling `sample_option` and `show.MATH` arguments respectively.  

`VAF_plot(maf_file, sample_option = "OFA", theme_option = "aaas", file_format = "png", show.MATH = T)`


## Shared/Private mutation
Knowing how many matations are shared and owned privately by samples of one patient is helpful for understanding the tumor heterogeneity.
We can use `mut_shard_private` function to visualize the intersect mutations and their types in several samples of one patient, by producing a stack plot.
The parameter "show.num" can be set to determine whether to show the numbers of each muatations in the plot.

`mut.shared_private(maf_file, patientID = c("tsb1"), show.num = FALSE)`


## Tumor_clone plot
If the cluster result of a patient and the information of locus are given, this function could visualize the outcomes by offering you a radar plot and a dotplot.
The plot could be changed according to the parameters `clone.min.mut` and `clone.min.aveCCF` you set.

`TumorClones_plot(patientID, ccf.dir = "", out.dir = "", clone.min.mut = 5, clone.min.aveCCF = 0.1)`


## Fishplot
With information of cluster and locus, fishplot could provide customers with an intuitive and accurate representation of how an individual tumor is changing over time, which could make analysis easier.
In addition, fish plot may also find inches outside of cancer biology and could represent the changing landscapes of microbial populations.
A clusterEstimates.tsv and a mutation_to_cluster.tsv files would be produced after processing the data input,

```
	prepareSchismInput(dir.cluster.tsv, dir.loci.tsv, dir.output)
	write.table(clusterEstimates.tsv)
	write.table(mutation_to_cluster.tsv)
	schism2Fishplot(clusterEstimates.tsv, mutation_to_cluster.tsv)
```


## GO anaysis
The GO database standardizes the gene products from functions, biological pathways and cell localization.
Through GO enrichment analysis, we can roughly understand where the differenal genes enrich, in what biological functions, pathways or cell localizations.
This function can offer a barplot and a dotplot to visualize the result of the GO enrichment, as well as some branch information extracted from the input njtree. You can get all/seleted type of analysis by setting the `type` parameter.
Also, `pval` and `qval` can be controlled to meet different needs.

`GO.njtree(njtree, GO.type = "BP", savePlot = T)`


## Pathway analysis
This function enables you to get metabolic pathway results and maps, which are analyzed based on the enriched genes.
The KEGG database links gene lists obtained from genomes that have been completely sequenced to higher levels of system functions at the cellular, species, and ecosystem levels.
And the Pathway analysis will offer you a clear plot showing enriched pathways.
You can choose between the kEGG analysis and Pathway analysis by controlling the `pathway.type` paramater.

`Pathway.njtree(njtree, pathway.type = "KEGG", savePlot = T)`


## Mutational Signature
In order to get a phylogenetic tree, this function can define branches' set relationship by re-labeling their tumor sample barcode from the smallest set. 
And it will calcualte each branch's mutational signature weight according to cosmic reference and pick the maxium. 
Finally, a data frame includes each set/branch's mutational signature will be offered.

`Mutational_sigs_tree(maf_file, branch_file)`


## NJtree plot
According to researches, constructing a cancer phylogenetic tree with mutation information could help people understand more about the heterogeneity of cancer in samples of certain petient. 
In a phylogenetic tree, the trunk represents shared mutations and the thinner branches represents private and low frequency muatations of different samples. Besides, the distances between branches show how close these samples are.
This function uses the method of Neighbor-joining to construct the phylogenetic tree.
This method minimizes the total distance of the phylogenetic tree by determining the nearest or adjacent paired classification units.
The maf_file would be sorted and transformed into an NJtree object before plotting NJtree. Apart from that, the trunk and branches are colored differently, in order to better show the signatures.

```
	maf <- read.Maf(patientID, dat.dir)
	njtree <- read.NJtree(maf_file, use.indel = T, use.ccf = F,mut.signature = TRUE, sig.min.mut.number = 50,)
	getMutSort(njtree)
	getPhyloTree(njtree)
	getNJtreeSignature(njtree)
```

# FAQ