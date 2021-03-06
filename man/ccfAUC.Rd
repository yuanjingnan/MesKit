% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ccfAUC.R
\name{ccfAUC}
\alias{ccfAUC}
\title{ccfAUC}
\usage{
ccfAUC(
  maf,
  patient.id = NULL,
  min.ccf = 0,
  withinTumor = FALSE,
  plot.density = TRUE,
  use.tumorSampleLabel = FALSE,
  ...
)
}
\arguments{
\item{maf}{A Maf or MafList object generated by \code{\link{readMaf}} function.}

\item{patient.id}{Select the specific patients. Default NULL, all patients are included.}

\item{min.ccf}{The minimum value of CCF. Default 0.}

\item{withinTumor}{Calculate between-region heterogeneity within tumor. (Default: FALSE).}

\item{plot.density}{Whether to show the density plot. (Default: TRUE).}

\item{use.tumorSampleLabel}{Logical (Default: FALSE). Rename the 'Tumor_Sample_Barcode' by 'Tumor_Sample_Label'.}

\item{...}{Other options passed to \code{\link{subMaf}}}
}
\value{
A list containing AUC of CCF and a graph
}
\description{
The tumor heterogeneity was estimated as the area under the curve (AUC) of the cumulative density function from all cancer cell fractions per tumor
}
\examples{
maf.File <- system.file("extdata/", "HCC_LDC.maf", package = "MesKit")
clin.File <- system.file("extdata/", "HCC_LDC.clin.txt", package = "MesKit")
ccf.File <- system.file("extdata/", "HCC_LDC.ccf.tsv", package = "MesKit")
maf <- readMaf(mafFile=maf.File, clinicalFile = clin.File, ccfFile=ccf.File, refBuild="hg19")
ccfAUC(maf)

}
\references{
Charoentong P, Finotello F, et al. Pan-cancer Immunogenomic Analyses Reveal Genotype-Immunophenotype Relationships and Predictors of Response to Checkpoint Blockade. Cell reports 2017, 18:248-262.
}
