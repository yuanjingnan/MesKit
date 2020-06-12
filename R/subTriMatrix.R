subTriMatrix <- function(phyloTree_list, CT = FALSE, withinTumor = FALSE){
  
  bases <- c("A","C","G","T")
  if(CT){
    types <- c("C>A","C>G","C>T at CpG","C>T other","T>A","T>C","T>G")
  }else{
    types <- c("C>A","C>G","C>T","T>A","T>C","T>G")
  }
  
  ## 96 trinucleotide 
  all_tri <- c()
  for(type in types){
    for(base.up in bases){
      for(base.down in bases){
        if(type == "C>T at CpG"){
          if(base.down != "G"){
            next
          }
        }
        tri <- paste(base.up,"[",type,"]",base.down,sep = "")
        all_tri <- append(all_tri,tri)
      }
    }
  }
  
  ref64_type <- c()
  ref64_seq <- c()
  for(base.mid in bases){
    base.mid1 <- base.mid
    for(base.up in bases){
      for(base.down in bases){
        tri <- paste(base.up,base.mid,base.down,sep = "")
        ref64_seq <- append(ref64_seq,tri)
        if(base.mid == "G"){
          base.mid1 <- "C"
        }
        else if(base.mid == "A"){
          base.mid1 <- "T"
        }
        n <- paste(base.up,base.mid1,base.down,sep = "")
        ref64_type <- append(ref64_type,n)
      }
    }
  }
  names(ref64_type) <- ref64_seq
  ref64 <- ref64_type
  # names(all_tri) <- seq96
  result <- list()
  for(phyloTree in phyloTree_list){
    
    patient <- getPhyloTreePatient(phyloTree)
    ## check reference
    refBuild <- getPhyloTreeRef(phyloTree)
    ref.options = c('hg18', 'hg19', 'hg38')
    if(!refBuild %in% ref.options){
      stop("Error:refBuild can only be either 'hg18', 'hg19' or 'hg38'")
    }else {
      refBuild <- paste("BSgenome.Hsapiens.UCSC.", refBuild, sep = "")
    }
    mut_branches <- phyloTree@mut.branches
    if(nrow(mut_branches) == 0){
      stop("Error: There are not enough mutations in ",patientID)
    }
    
    origin_context <- Biostrings::getSeq(get(refBuild),
                                         Rle(paste("chr",mut_branches$Chromosome,sep = "")),
                                         mut_branches$Start_Position-1,
                                         mut_branches$Start_Position+1) 
    origin_context <- as.character(origin_context)
    context <- ref64[origin_context]
    
    mut_types <- paste(mut_branches$Reference_Allele, mut_branches$Tumor_Allele, sep = ">")
    mut_types = gsub('G>T', 'C>A', mut_types)
    mut_types = gsub('G>C', 'C>G', mut_types)
    mut_types = gsub('G>A', 'C>T', mut_types)
    mut_types = gsub('A>T', 'T>A', mut_types)
    mut_types = gsub('A>G', 'T>C', mut_types)
    mut_types = gsub('A>C', 'T>G', mut_types)
    
    mut_branches$mut_type <- mut_types
    mut_branches$origin_context <- origin_context
    mut_branches$context <- context
    
    if(!CT){
      mut_branches <- mut_branches %>% 
        dplyr::rowwise() %>% 
        dplyr::mutate(context = paste0(strsplit(context,"")[[1]][1],
                                       "[", mut_type, "]",
                                       strsplit(context,"")[[1]][3])) %>% 
        as.data.frame()
    }else{
      CpG = c("ACG", "CCG", "TCG", "GCG")
      mut_branches <- mut_branches %>% 
        dplyr::rowwise() %>% 
        dplyr::mutate(context = dplyr::case_when(
          mut_type == "C>T" & origin_context %in% CpG ~  
            paste0(strsplit(context,"")[[1]][1],"[C>T at CpG]",strsplit(context,"")[[1]][3]),
          mut_type == "C>T" & !origin_context %in% CpG ~  
            paste0(strsplit(context,"")[[1]][1],"[C>T other]",strsplit(context,"")[[1]][3]),
          mut_type != "C>T" ~ 
            paste0(strsplit(context,"")[[1]][1],"[", mut_type, "]",strsplit(context,"")[[1]][3])
        )) %>% 
        as.data.frame()
    }
    
    if(withinTumor){
      branch_data_list <- split(mut_branches, mut_branches$Mutation_Type)
    }else{
      branch_data_list <- split(mut_branches, mut_branches$Branch_ID)
    }
    
    
    
    tri_matrix <- data.frame()
    for(branch_data in branch_data_list){
      
      branch_count <- table(branch_data$context)
      branch_count <- branch_count[names(branch_count) %in% all_tri] 
      
      m <- branch_count[all_tri]
      m[is.na(m)] <- 0
      names(m) <- all_tri
      
      branch_matrix <- matrix(m, ncol = length(all_tri), nrow = 1)
      colnames(branch_matrix) <- as.character(all_tri)
      
      tri_matrix <- rbind(tri_matrix, as.data.frame(branch_matrix)) 
    }
    rownames(tri_matrix) <- names(branch_data_list)
    
    result[[patient]] <- as.matrix(tri_matrix)  
  }
  return(result)
}