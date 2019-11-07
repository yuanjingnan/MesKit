**The MAF files**

MAF files contain many fields of information about chromosome and gene mutations and their annotations. The following fields are highly recommended to be contained in the MAF files.

Hugo_Symbol, Chromosome, Start_Position, End_Position, Variant_Classification, Variant_Type, Reference_Allele, Tumor_Seq_Allele2, VAF, Tumor_Sample_Barcode.

**Example MAF file**

| Hugo_Symbol|  Chromosome | Start_Position | End_Position |  Variant_Classification | Variant_Type | Reference_Allele |  Tumor_Seq_Allele1 | Tumor_Seq_Allele2 | Ref_allele_depth |  Alt_allele_depth |  VAF | CDS_Change  | Protein_Change |  Tumor_Sample_Barcode |
|:-----| :------| :------ | :----- | :------ | :----- | :---- | :-----| :----- | :----- | :-------| :---- | :-----| :----- | :----- |
| LOC729737| 1 | 135207 | 135207  | RNA | SNP | C | C | G | 40  | 4 | 0.0909 | NA | NA | 311252-S |
|TTC34,ACTRT2| 1 | 2869474 | 2869474 |  IGR |INS | - | | CTCTCT | 43 | 8 | 0.1568 | NA |  NA | 311252-S |
|NBPF1|1 | 16908223 | 16908223 | Intron | SNP | T | T |A| 142| 8 | 0.0533 | NA| NA | 311252-S|
|PRAMEF2 | 1 | 12921600 | 12921600 | Missense_Mutation | SNP | C |  C | T |73 | 3 | 0.0394 | c.C1391T | p.P464L | 311252-S |