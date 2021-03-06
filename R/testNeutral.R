#' testNeutral
#' @description Evaluate whether a tumor follows neutral evolution or under strong selection during the growth based on variant frequency distribution (VAF) of subclonal mutations.
#' The subclonal mutant allele frequencies of a follow a simple power-law distribution predicted by neutral growth.  
#' 
#' @references Williams, M., Werner, B. et al. Identification of neutral tumor evolution across cancer types. Nat Genet 48, 238-244 (2016) 
#' 
#' @param maf Maf or MafList object generated by \code{\link{readMaf}} function.
#' @param patient.id Select the specific patients. Default NULL, all patients are included.
#' @param withinTumor Test neutral within tumros in each patients. (Default: FALSE).
#' @param min.total.depth The minimun total depth of coverage. Defalut 2
#' @param min.vaf The minimum value of adjusted VAF value. Default 0.1
#' @param max.vaf The maximum value of adjusted VAF value. Default 0.3
#' @param R2.threshold The threshod of R2 to decide whether a tumor follows neutral evolution. Default 0.98
#' @param min.mut.count The minimun number of subclonal mutations used to fit model. Default 20
#' @param plot Logical, whether to print model fitting plot of each sample. (Default: TRUE).
#' @param use.tumorSampleLabel Let Tumor_Sample_Barcode replace Tumor_Sample_Label if Tumor Label is provided in clinical data. (Default FALSE).
#' @param ... Other options passed to \code{\link{subMaf}}
#' 
#' @return the neutrality metrics and model fitting plots
#' 
#' @examples
#' maf.File <- system.file("extdata/", "HCC_LDC.maf", package = "MesKit")
#' clin.File <- system.file("extdata/", "HCC_LDC.clin.txt", package = "MesKit")
#' ccf.File <- system.file("extdata/", "HCC_LDC.ccf.tsv", package = "MesKit")
#' maf <- readMaf(mafFile=maf.File, clinicalFile = clin.File, ccfFile=ccf.File, refBuild="hg19")
#' testNeutral(maf)
#' @importFrom stats approxfun integrate lm
#' @export testNeutral

testNeutral <- function(maf,
                        patient.id = NULL,
                        withinTumor = FALSE, 
                        min.total.depth = 2, 
                        min.vaf = 0.1, 
                        max.vaf = 0.3,
                        R2.threshold = 0.98,
                        min.mut.count = 20,
                        plot = TRUE,
                        use.tumorSampleLabel = FALSE,
                        ...){
  
  
  result <- list()
  
  processTestNeutral <- function(m){
    maf_data <- getMafData(m)
    patient <- getMafPatient(m)
    if(nrow(maf_data) == 0){
      message("Warning: there was no mutation in ", patient, " after filtering.")
      return(NA)
    }
    
    patient <- unique(maf_data$Patient_ID)
    if(! "CCF" %in% colnames(maf_data)){
      stop("CCF data ia required for inferring whether a tumor follows neutral evolution.")
    }
    
    neutrality.metrics <- data.frame()
    if(plot){
      model.fitting.plot <- list()
    }
    
    if(withinTumor){
      ids <- unique(maf_data$Tumor_ID)
    }else{
      ids <- unique(maf_data$Tumor_Sample_Barcode)
    }
    
    processTestNeutralID <- function(id){
      if(withinTumor){
        subdata <- subset(maf_data, maf_data$Tumor_ID == id & !is.na(maf_data$Tumor_Average_VAF_adj))
        subdata$VAF_adj <- subdata$Tumor_Average_VAF_adj
      }else{
        subdata <- subset(maf_data, maf_data$Tumor_Sample_Barcode == id & !is.na(maf_data$VAF_adj))
      }
      ## warning
      if(nrow(subdata) < min.mut.count){
        warning(paste0("Eligible mutations of sample ", id, " from ", patient, " is not enough for testing neutral evolution."))
        return(NA)
      }
      
      vaf <- subdata$VAF_adj
      breaks <- seq(max.vaf, min.vaf, -0.005)
      mut.count <- unlist(lapply(breaks,function(x,vaf){length(which(vaf > x))},vaf = vaf))  
      vafCumsum <- data.frame(count = mut.count, f = breaks)
      vafCumsum$inv_f <- 1/vafCumsum$f - 1/max.vaf
      vafCumsum$n_count <- vafCumsum$count/max(vafCumsum)
      vafCumsum$t_count <- vafCumsum$inv_f/(1/min.vaf - 1/max.vaf)
      ## area of theoretical curve
      theoryA <- stats::integrate(stats::approxfun(vafCumsum$inv_f,vafCumsum$t_count),
                                  min(vafCumsum$inv_f),
                                  max(vafCumsum$inv_f),stop.on.error = FALSE)$value
      # area of emprical curve
      dataA <- stats::integrate(approxfun(vafCumsum$inv_f,vafCumsum$n_count),
                                min(vafCumsum$inv_f),
                                max(vafCumsum$inv_f),stop.on.error = FALSE)$value
      # Take absolute difference between the two
      area <- abs(theoryA - dataA)
      # Normalize so that metric is invariant to chosen limits
      area<- area / (1 / min.vaf - 1 / max.vaf)
      
      
      ## calculate mean distance
      meandist <- mean(abs(vafCumsum$n_count - vafCumsum$t_count))
      
      ## calculate kolmogorovdist 
      n = length(vaf)
      cdfs <- 1 - ((1/sort(vaf) - 1/max.vaf) /(1/min.vaf - 1/max.vaf))
      dp <- max((seq_len(n)) / n - cdfs)
      dn <- - min((0:(n-1)) / n - cdfs)
      kolmogorovdist  <- max(c(dn, dp))
      
      ## R squared
      lmModel <- stats::lm(vafCumsum$count ~ vafCumsum$inv_f + 0)
      lmLine = summary(lmModel)
      R2 = lmLine$adj.r.squared
      
      if(withinTumor){
        test.df <- data.frame(
          Patient_ID = patient,
          Tumor_ID = id,
          Eligible_Mut_Count = nrow(subdata),
          Area = area,
          Kolmogorov_Distance = kolmogorovdist,
          Mean_Distance = meandist,
          R2 = R2, 
          Type = dplyr::if_else(
            R2 >= R2.threshold,
            "neutral",
            "non-neutral") 
        )
      }else{
        test.df <- data.frame(
          Patient_ID = patient,
          Tumor_Sample_Barcode = id,
          Eligible_Mut_Count = nrow(subdata),
          Area = area,
          Kolmogorov_Distance = kolmogorovdist,
          Mean_Distance = meandist,
          R2 = R2, 
          Type = dplyr::if_else(
            R2 >= R2.threshold,
            "neutral",
            "non-neutral") 
        ) 
      }
      if(plot){
        p <- plotPowerLaw(vafCumsum = vafCumsum, test.df =  test.df, id = id,
                          max.vaf = max.vaf, lmModel = lmModel, patient = patient)
        model.fitting.plot[[id]] <- p
      }
      return(list(test.df = test.df, p = p))
    }
    
    id_result <- lapply(ids, processTestNeutralID)
    idx <- which(!is.na(id_result))
    id_result <- id_result[idx]

    neutrality.metrics <- lapply(id_result, function(x)x$test.df) %>% dplyr::bind_rows()
    model.fitting.plot <- lapply(id_result, function(x)x$p)
    names(model.fitting.plot) <- ids[idx]
    
    if(nrow(neutrality.metrics) == 0){
      return(NA)
    }
    if(plot){
      return(list(
        neutrality.metrics = neutrality.metrics,
        model.fitting.plot = model.fitting.plot
      ))
    }else{
      return(neutrality.metrics)
    }
    
  }
  
  if(min.vaf <= 0){
    stop("'min.vaf' must be greater than 0")
  }
  if(max.vaf < min.vaf){
    stop("'max.vaf' must be greater than min.vaf")
  }
  
  maf_input <- subMaf(maf, 
                      min.vaf = min.vaf, 
                      max.vaf = max.vaf, 
                      min.total.depth = min.total.depth,
                      clonalStatus = "Subclonal",
                      mafObj = TRUE,
                      patient.id = patient.id,
                      use.tumorSampleLabel = use.tumorSampleLabel,
                      ...)
  
  result <- lapply(maf_input, processTestNeutral)
  result <- result[!is.na(result)]
  
  if(length(result) > 1){
    return(result)
  }else if(length(result) == 0){
    return(NA)
  }else{
    return(result[[1]])
  }
}


# if(plot){
#     ## combind data of all patients
#     violin.data <- do.call(dplyr::bind_rows, testNeutral.out$neutrality.metrics)
#     if(nrow(violin.data) != 0){
#         y.min <- floor(min(violin.data$R2)*10)/10 
#         breaks.y <-  seq(y.min, 1, (1-y.min)/3)
#         p.violin <- ggplot(data = violin.data,aes(x = Patient, y = R2, fill = Patient))+
#             geom_violin(trim=T,color="black")+
#             geom_boxplot(width=0.05,position=position_dodge(0.9))+
#             geom_hline(yintercept = R2.threshold,linetype = 2,color = "red")+
#             theme_bw() + 
#             ylab(expression(italic(R)^2))+
#             scale_y_continuous(breaks = breaks.y, labels = round(breaks.y,3),
#                                limits = c(breaks.y[1],1))+
#             ## line of axis y
#             geom_segment(aes(y = y.min ,
#                              yend = 1,
#                              x=-Inf,
#                              xend=-Inf),
#                          size = 1.5)+
#             theme(axis.text.x=element_text(vjust = .3 ,size=10,color = "black",angle = 90), 
#                   axis.text.y=element_text(size=10,color = "black"), 
#                   axis.line.x = element_blank(),
#                   axis.ticks.x = element_blank(),
#                   axis.ticks.length = unit(.25, "cm"),
#                   axis.line.y = element_blank(),
#                   axis.ticks.y = element_line(size = 1),
#                   axis.title.y=element_text(size = 15), 
#                   axis.title.x=element_blank(), 
#                   panel.border = element_blank(),axis.line = element_line(colour = "black",size=1),
#                   legend.text=element_text( colour="black", size=10),
#                   legend.title= element_blank(),
#                   panel.grid.major = element_line(linetype = 2),
#                   panel.grid.minor = element_blank()) 
#         testNeutral.out$R2.values.plot <- p.violin
#     }
#     else{
#         p.violin <- NA
#     }
#     
# }