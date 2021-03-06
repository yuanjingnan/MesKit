% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/methods.R
\name{getCCFMatrix}
\alias{getCCFMatrix}
\alias{getCCFMatrix,phyloTree-method}
\title{getCCFMatrix}
\usage{
getCCFMatrix(object)

\S4method{getCCFMatrix}{phyloTree}(object)
}
\arguments{
\item{object}{An object of phyloTree}
}
\value{
CCF matrix of phyloTree
}
\description{
getCCFMatrix
}
\examples{
maf.File <- system.file("extdata/", "HCC_LDC.maf", package = "MesKit")
clin.File <- system.file("extdata/", "HCC_LDC.clin.txt", package = "MesKit")
ccf.File <- system.file("extdata/", "HCC_LDC.ccf.tsv", package = "MesKit")
maf <- readMaf(mafFile=maf.File, clinicalFile = clin.File, ccfFile=ccf.File, refBuild="hg19")
phyloTree <- getPhyloTree(maf)
getCCFMatrix(phyloTree$HCC5647)
}
