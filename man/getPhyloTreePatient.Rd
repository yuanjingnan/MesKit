% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/methods.R
\name{getPhyloTreePatient}
\alias{getPhyloTreePatient}
\alias{getPhyloTreePatient,phyloTree-method}
\title{getPhyloTreePatient}
\usage{
getPhyloTreePatient(object)

\S4method{getPhyloTreePatient}{phyloTree}(object)
}
\arguments{
\item{object}{An object of phyloTree}
}
\value{
patientID of phyloTree
}
\description{
getPhyloTreePatient
}
\examples{
maf.File <- system.file("extdata/", "HCC_LDC.maf", package = "MesKit")
clin.File <- system.file("extdata/", "HCC_LDC.clin.txt", package = "MesKit")
ccf.File <- system.file("extdata/", "HCC_LDC.ccf.tsv", package = "MesKit")
maf <- readMaf(mafFile=maf.File, clinicalFile = clin.File, ccfFile=ccf.File, refBuild="hg19")
phyloTree <- getPhyloTree(maf)
getPhyloTreePatient(phyloTree$HCC5647)
}
