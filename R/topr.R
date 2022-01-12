#'  topr
#'
#' @description A package for viewing and annotating genetic association data
#' @docType package
#' @name topr
#' @section topr functions:
#' The main plotting functions are:
#' * \code{\link{manhattan}} to create Manhattan plot of association results
#' * \code{\link{regionplot}} to create regional plots of association results for smaller genetic regions
#' @examples
#' library(topr)
#' # Create a manhattan plot using
#' manhattan(CD_UKBB)
#'
#' # Create a regional plot
#' regionplot(CD_UKBB, gene="IL23R")
#' 
#' # Get the lead/index snps (the top snp per MB window)
#' get_best_snp_per_MB(CD_UKBB)
#' 
#' # Annotate the index snps with their nearest gene
#' index_snps <- get_best_snp_per_MB(CD_UKBB)
#' annotate_with_nearest_gene(index_snps)

NULL
