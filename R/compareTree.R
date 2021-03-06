#' compareTree
#' @description Compares two phylogenetic trees and returns a detailed report of several distance methods
#' 
#' 
#' @param phyloTree1 A phyloTree object generated by \code{\link{getPhyloTree}} function.
#' @param phyloTree2 A phyloTree object generated by \code{\link{getPhyloTree}} function.
#' @param plot Logical (Default: FALSE). If TRUE, two trees will be plotted on the same device and their similarities will be shown.
#' @param min.ratio Double, Default 1/20. If min.ratio is not NULL,
#' all edge length which are smaller than min.ratio*the longest edge length will be reset as min.ratio*longest edge length. 
#' @param show.bootstrap Logical (Default: FALSE). Whether to add bootstrap value on internal nodes.
#' @param common.col Color of common branches.
#' @param use.tumorSampleLabel Logical (Default: FALSE). Rename the 'Tumor_Sample_Barcode' by 'Tumor_Sample_Label'.
#' 
#' @return A vector containing the following tree distance methods by R package phangorn
#' Symmetric.difference  Robinson-Foulds distance
#' KF-branch distance  the branch score distance (Kuhner & Felsenstein 1994)
#' Path.difference  difference in the path length, counted as the number of branches 
#' Weighted.path.difference	 difference in the path length, counted using branches lengths
#' 
#' @examples
#' maf.File <- system.file("extdata/", "HCC_LDC.maf", package = "MesKit")
#' clin.File <- system.file("extdata/", "HCC_LDC.clin.txt", package = "MesKit")
#' ccf.File <- system.file("extdata/", "HCC_LDC.ccf.tsv", package = "MesKit")
#' maf <- readMaf(mafFile=maf.File, clinicalFile = clin.File, ccfFile=ccf.File, refBuild="hg19")
#' 
#' 
#' phyloTree1 <- getPhyloTree(maf$HCC5647, method = "NJ")
#' phyloTree2 <- getPhyloTree(maf$HCC5647, method = "MP")
#' compareTree(phyloTree1, phyloTree2)
#' compareTree(phyloTree1, phyloTree2, plot = TRUE)
#' @export compareTree

compareTree <- function(phyloTree1,
                        phyloTree2,
                        plot = FALSE,
                        min.ratio = 1/20,
                        show.bootstrap = FALSE,
                        common.col = "red",
                        use.tumorSampleLabel = FALSE){
    
    if(min.ratio <= 0){
        stop("min.ratio must greater than 0")
    }
	tree1 <- getTree(phyloTree1)
	tree2 <- getTree(phyloTree2)
	dist <- phangorn::treedist(tree1, tree2)
	names(dist) <- c("Symmetric.difference", "KF-branch distance", "Path difference", "Weighted path difference")
	if(plot){
	    compare <- TRUE
	    if(!is.null(min.ratio)){
	        min1 <- max(tree1$edge.length)*min.ratio
	        min2 <- max(tree2$edge.length)*min.ratio
	        tree1$edge.length[tree1$edge.length < min1] <- min1
	        tree2$edge.length[tree2$edge.length < min2] <- min2
	        if(use.tumorSampleLabel){
	          tsb.label <- getPhyloTreeTsbLabel(phyloTree1)
	          if(nrow(tsb.label) == 0){
        		stop("Tumor_Sample_Label was not found. Please check clinical data or let use.tumorSampleLabel be 'FALSE'")
	            
	          }
	        }
	        phyloTree1 <- new('phyloTree',
	                          patientID = getPhyloTreePatient(phyloTree1),
	                          tree = tree1, 
	                          binary.matrix = getBinaryMatrix(phyloTree1),
	                          ccf.matrix = getCCFMatrix(phyloTree1), 
	                          mut.branches = getMutBranches(phyloTree1),
	                          branch.type = getBranchType(phyloTree1),
	                          ref.build = getPhyloTreeRef(phyloTree1),
	                          bootstrap.value = getBootstrapValue(phyloTree1),
	                          method = getTreeMethod(phyloTree1),
	                          tsb.label = getPhyloTreeTsbLabel(phyloTree1))
	        phyloTree2 <- new('phyloTree',
	                          patientID = getPhyloTreePatient(phyloTree2),
	                          tree = tree2, 
	                          binary.matrix = getBinaryMatrix(phyloTree2),
	                          ccf.matrix = getCCFMatrix(phyloTree2), 
	                          mut.branches = getMutBranches(phyloTree2),
	                          branch.type = getBranchType(phyloTree2),
	                          ref.build = getPhyloTreeRef(phyloTree2),
	                          bootstrap.value = getBootstrapValue(phyloTree2),
	                          method = getTreeMethod(phyloTree2),
	                          tsb.label = getPhyloTreeTsbLabel(phyloTree2))
	    }
	    treedat1 <- getTreeData(phyloTree1, compare = compare)
	    treedat2 <- getTreeData(phyloTree2, compare = compare)
	    m12 <- match(treedat1[sample == "internal node",]$label, treedat2[sample == "internal node",]$label)
	    if(length(m12[!is.na(m12)]) > 0){
	        cat(paste0("Both tree have ",length(m12[!is.na(m12)]), " same branches"))
	        treedat1$is.match <- 'NO'
	        treedat2$is.match <- 'NO'
	        x <- 1
	        for(i in seq_len(length(m12))){
	            if(is.na(m12[i])){
	                next
	            }
	            else{
	                pos1 <- which(treedat1$end_num == treedat1[treedat1$sample == "internal node",]$end_num[i])
	                pos2 <- which(treedat2$end_num == treedat2[treedat2$sample == "internal node",]$end_num[m12[i]])
	                treedat1$is.match[pos1] <- paste0("com", x)
	                treedat2$is.match[pos2] <- paste0("com", x)
	                x <- x + 1
	            }
	        }
	    }else{
	        cat("Both tree have not same branches")
	        return(dist)
	    }
	    
	    p1 <- plotTree(phyloTree1,
	                   treeData = treedat1,
	                   show.bootstrap = show.bootstrap,
	                   min.ratio = min.ratio,
	                   common.col = common.col,
	                   branchCol = NULL,
	                   use.tumorSampleLabel = use.tumorSampleLabel)
	    p2 <- plotTree(phyloTree2,
	                   treeData = treedat2,
	                   show.bootstrap = show.bootstrap,
	                   min.ratio = min.ratio,
	                   common.col = common.col,
	                  branchCol = NULL,
	                  use.tumorSampleLabel = use.tumorSampleLabel)
	    ptree <- cowplot::plot_grid(p1,
	                                p2,
	                                labels = c(getTreeMethod(phyloTree1),getTreeMethod(phyloTree2))
	                                )
	    # p <- ggpubr::ggarrange(p1, p2, nrow =1, common.legend = TRUE, legend="top",labels = c(phyloTree1@method,phyloTree2@method))
	    return(list(compare.dist = dist, compare.plot = ptree))
	}else{
	  return(dist)
	}
    
}
