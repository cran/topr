
set_size_shape_alpha <- function(df,size,shape,alpha,locuszoomplot=F){
  df <- set_size(df,size, locuszoomplot = locuszoomplot)
  df <- set_shape(df,shape,locuszoomplot = locuszoomplot)
  df <- set_alpha(df,alpha)
  if(!locuszoomplot){
    df <- set_shape_by_impact(df)
  }
  return(df)
}

set_shape_by_impact <- function(dat){
  for(i in seq_along(dat)){
    if("Max_Impact" %in% colnames(dat[[i]])){
      dat[[i]]$shape0 <- ifelse(dat[[i]]$Max_Impact == "MODERATE", 17, dat[[i]]$shape)
      dat[[i]]$shape <- ifelse(dat[[i]]$Max_Impact =="HIGH", 8, dat[[i]]$shape0)
    }
  }
  return(dat)
}

set_annotate <- function(dat,annotate){
  if(! is.null(annotate)){
    for(i in seq_along(dat)){
      if(!is.null(annotate) & nrow(dat[[i]]>0)){
        if(is.vector(annotate) & (length(annotate) >= i))
          dat[[i]]$annotate <- annotate[i]
        else
          dat[[i]]$annotate <- annotate
      }
    }
  }
  return(dat)
}

set_color <- function(dat,color,shades_alpha=0.5, use_shades=T, chr_lightness=0.80, chr=NULL){
  if(length(color) < length(dat))
    stop(paste("There are ",length(dat), " datasets, but only ",length(color), " color. Add more colors with the color argument, eg. color=c(\"blue\",\"yellow\",\"green\", etc)"))
  for(i in seq_along(dat)){
    if(!is.null(color) & nrow(dat[[i]]>0)){
      if(is.vector(color) & (length(color) >= i)){
        if(use_shades || !(is.null(chr))){
          dat[[i]]$color <- color[i]
        }
        else{                  
          even_chr_color <- lightness(color[i], get_chr_lightness(chr_lightness,i) )
          dat[[i]]$color <- ifelse((as.numeric(dat[[i]]$CHROM) %% 2) == 0, even_chr_color , color[i]) 
        }
      }
      else
        dat[[i]]$color <- color
    }
  }
  return(dat)
}

get_chr_lightness <- function(chr_lightness, i){
   if(is.null(chr_lightness) || !is.numeric(chr_lightness))
     chr_lightness <- 0.8
   if(is.vector(chr_lightness)){
     if(length(chr_lightness) >= i)
        chr_lightness <- chr_lightness[i]
    else
        chr_lightness <- chr_lightness[length(chr_lightness)]
   }
  return(chr_lightness)
}




set_size <- function(dat,size, locuszoomplot = locuszoomplot){
  if(is.null(size))
    size <- 1
  for(i in seq_along(dat)){
    if(!is.null(size) & nrow(dat[[i]]>0)){
      if(is.vector(size) &  length(size) >= i )
        dat[[i]]$size <- size[i]
      else
        dat[[i]]$size <- size
    }
    if(locuszoomplot & ("R2" %in% colnames(dat[[i]]))){
      dat[[i]]$size <- ifelse(dat[[i]]$R2 == 1, dat[[i]]$size*1.5, dat[[i]]$size)
      #handle NA values for R2
      dat[[i]]$size[is.na(dat[[i]]$size)] <- size
    }
  }
  return(dat)
}

set_alpha <- function(dat,alpha){
  if(is.null(alpha))
    alpha <- 0.7
  for(i in seq_along(dat)){
    if(!is.null(alpha) & nrow(dat[[i]]>0)){
      if(is.vector(alpha) & (length(alpha) >= i))
        dat[[i]]$alpha <- alpha[i]
      else
        dat[[i]]$alpha <- alpha
    }
  }
  return(dat)
}

set_shape <- function(dat,shape,locuszoomplot=F){
  if(is.null(shape))
    shape <- 19
  for(i in seq_along(dat)){
    if(!is.null(shape) & nrow(dat[[i]]>0)){
      if(is.vector(shape) & (length(shape) >= i))
        dat[[i]]$shape <- shape[i]
      else
        dat[[i]]$shape <- shape
    }
    if(locuszoomplot & ("R2" %in% colnames(dat[[i]]))){
        dat[[i]]$shape <- ifelse(dat[[i]]$R2 == 1, 18, dat[[i]]$shape)
        dat[[i]]$shape[is.na(dat[[i]]$shape)] <- shape
    }
  }
  return(dat)
}

set_log10p <- function(dat, ntop){
  for(i in seq_along(dat)){
    df <- dat[[i]]
    if(ntop > length(dat)){ ntop <- length(dat)}
    if(i <= ntop){
      dat[[i]] <- df %>% dplyr::mutate(log10p=-log10(P))

    }else{
      dat[[i]] <- df %>% dplyr::mutate(log10p=log10(P))
    }
  }
  return(dat)
}

add_log10p_wo_trans <- function(dat, ntop){
  for(i in seq_along(dat)){
    df <- dat[[i]]
    if(ntop > length(dat)){ ntop <- length(dat)}
    if(i <= ntop){
      dat[[i]] <- df %>% dplyr::mutate(log10p=P)
      
    }else{
      dat[[i]] <- df %>% dplyr::mutate(log10p=P)
    }
  }
  return(dat)
}


get_db <- function(build){
   if(is.character(build) || is.numeric(build)){
    if(tolower(build) %in% c("38","hg38","grch38"))
      db <- enshuman::hg38
    else if(tolower(build) %in% c("37","hg37","grch37"))
      db <- enshuman::hg37
    else{
      ext_db <- get(build)
      if(is.data.frame(class(ext_db))){
         db <- ext_db
      }
      else if(is.list(class(ext_db))){
        warning(paste("The provided build is a list. It has to be either a number, string or a data frame!\n Using the default build enshuman::hg38 instead" ))
        db <- enshuman::hg38
      }
      else{
        warning(paste("Could not find a build called [",build,"] to use for annotation. \n Using the default build GRCh38 (build=38) instead. ", sep=""))
        db <- enshuman::hg38
      }
    }
  }
  else if(is.data.frame(build)){
       db <- build 
  }
  else if(is.list(class(build))){
    warning(paste("The provided build is a list. It has to be either a number, string or a data frame! \n Using the default build GRCh38 (build=38) instead."))
    db <- enshuman::hg38
    }
  else{
    warning(paste("The build is not in the correct format. It has to be either a number,string or a data frame!\nUsing the default build GRCh38 (build=38) instead. ", sep=""))
    db <- enshuman::hg38
  }
  return(db)    
}


get_genes <- function(chr,xmin=0,xmax=NULL,protein_coding_only=FALSE, build=38){
  if(is.null(xmax)){
    xmax <- chr_lengths[chr_lengths$V1 == chr,]$V2
  }
  chr <- gsub("chr", "", chr)
  if(chr == "23"){ chr="X"}
  
  genes <-  get_db(build=build) %>% dplyr::filter(chrom==chr) %>% dplyr::select(-exon_chromstart,-exon_chromstart) %>% dplyr::filter(gene_start>xmin & gene_start<xmax | gene_end > xmin & gene_end < xmax | gene_start < xmin & gene_end>xmax | gene_start == xmin | gene_end == xmax)

  if(protein_coding_only)  
      genes <- genes %>% dplyr::filter(biotype=="protein_coding")
   return(genes)
}

get_exons <- function(chr,xmin=0,xmax=NULL,protein_coding_only=FALSE, build=38){
  if(is.null(xmax)){
    xmax <- chr_lengths[chr_lengths$V1 == chr,]$V2
  }
  chr <- gsub("chr", "", chr)
  if(chr == "23"){ chr="X"}
  
  exons <- get_db(build=build)  %>% dplyr::filter(chrom==chr)  %>% dplyr::filter(gene_start>xmin & gene_start<xmax | gene_end > xmin & gene_end < xmax | gene_start < xmin & gene_end>xmax | gene_start == xmin | gene_end == xmax)
  
  if(protein_coding_only)  
    exons <- exons %>% dplyr::filter(biotype=="protein_coding")
  return(exons)
}


get_chr_from_df <- function(df){
  #take the chromosome from the dataframe
  if(length(unique(df$CHROM)) == 1)
    chr <- unique(df$CHROM)
  else
    stop("More than one chromosome in the input data, please select which chromosome to display by setting the chr argument (e.g. chr='chr10') or use input data with just one chromosome")
  return(chr)
}


get_shades <- function(chr_lengths_and_offsets,dat,ntop=ntop,include_chrX=FALSE,ymin=NULL,ymax=NULL){
  coords <- get_x1_x2(chr_lengths_and_offsets)
  y1 <- c(rep(0, coords$n_offsets))  #if there is no bottom plot
  if(is.null(ymin))
    ymin <- get_ymin(dat)
  if(length(dat) > ntop)
    y1 <- c(rep(ymin, coords$n_offsets))
  if(is.null(ymax))
    ymax <- get_ymax(dat)
   
  shades <- data.frame(x1 = coords$x1,
                        x2 = coords$x2,
                        y1 = y1,
                        y2 = c(rep(ymax, coords$n_offsets)))

  return(shades)
}

get_x1_x2 <- function(chr_lengths_and_offsets){
  chrs <- chr_lengths_and_offsets$CHROM
  n_offsets <- floor(length(chrs)/2)
  offsets <- stats::setNames(chr_lengths_and_offsets$offset,chr_lengths_and_offsets$CHROM)

  x1 <- c()
  even_no <- as.numeric(subset(chrs, chrs %% 2 == 0))
  for(i in 1:length(even_no)){
    x1 <- c(x1, offsets[[even_no[i]]])
  }
  x2 <- c()
  odd_no <- as.numeric(subset(chrs, chrs %% 2 != 0))
 
   if(length(odd_no) > 1){
    for(i in 2:length(odd_no)){
      x2 <- c(x2, offsets[[odd_no[i]]])
    }
  }
  else if(length(odd_no) == length(even_no) & length(odd_no) == 1) {
    last_chr <- even_no[length(even_no)]
    last_chr_length_df <- chr_lengths_and_offsets %>% filter(CHROM == last_chr ) 
    last_chr_length <- last_chr_length_df$m
    final_x2 <- offsets[[last_chr]] + last_chr_length*1.02 
    x2 <- c(x2, final_x2)
  }
  if(length(x1) > length(x2)){
    last_chr <- even_no[length(even_no)]
    last_chr_length_df <- chr_lengths_and_offsets %>% filter(CHROM == last_chr ) 
    last_chr_length <- last_chr_length_df$m
    final_x2 <- offsets[[last_chr]] + last_chr_length*1.02 
    x2 <- c(x2, final_x2)
  }
  return(list(x1=x1, x2=x2,n_offsets=n_offsets))
}




get_ymax <- function(dat){
  ymax <- 0
  if(is.data.frame(dat)) dat <- list(dat)
  for(i in seq_along(dat)){
    if(length(dat[[i]]$log10p) > 0){
      tmp <- max(dat[[i]]$log10p)
      if(tmp>ymax){
        ymax <- tmp
      }
    }
  }
  return(ymax)
}

get_ymin <- function(dat){
  ymin <- 5
  if(is.data.frame(dat)) dat <- list(dat)
    for(i in seq_along(dat)){
      if(length(dat[[i]]$log10p) > 0){
        tmp <- min(dat[[i]]$log10p)
        if(tmp<ymin){
          ymin <- tmp
      }
    }
    }
  return(ymin)
}

get_chr_lengths_and_offsets <- function(dat, get_chr_lengths_from_data){
  if(get_chr_lengths_from_data){
    chrs <- get_chrs_from_data(dat) %>% as.numeric()
    chrs2plot <- get_max_value_by_chr_from_data(dat, chrs)
  }
  else{
    #create the offsets from the internal chr_lengths data
    chr_lengths$CHROM <- gsub("chr","", chr_lengths$V1)
    chr_lengths <- chr_lengths %>% dplyr::filter(! V1 %in% c("chrM") )
    chr_lengths[chr_lengths$CHROM=="X",'CHROM'] <- "23"
    chr_lengths[chr_lengths$CHROM=="Y",'CHROM'] <- "24"
    chr_lengths$CHROM <- as.integer(chr_lengths$CHROM)
    chrs <- c(1:23)
    chrs2plot <- chr_lengths %>% filter(CHROM %in% chrs)
  }
  chr_lengths_and_offsets <- chrs2plot %>% dplyr::group_by(CHROM) %>% dplyr::summarize(m=V2) %>% dplyr::mutate(offset=cumsum(as.numeric(lag(m, default=0))))
  return(chr_lengths_and_offsets)
}


get_ticks <- function(dat,chr_lengths_and_offsets,chr_ticknames,chr_map, show_all_chrticks=FALSE, hide_chrticks_from_pos=17, hide_chrticks_to_pos=NULL, hide_every_nth_chrtick=2, get_chr_lengths_from_data=T){
  df <- dat[[1]]
  for(i in seq_along(dat)){ if(length(unique(dat[[i]]$CHROM))  > length(unique(df$CHROM))){ df <- dat[[i]] } }
  ticknames=NULL
   if(!is.null(chr_ticknames)){
    if(length(names(chr_map)) == length(chr_ticknames))
      ticknames=chr_ticknames
    else
      warning(paste0("The length of the provided chr_ticknames vector [",length(chr_ticknames),"] does not match the number of chromosomes in the dataset(s) [", length(chr_map), "]. Using the default chr_ticknames instead!!"))
  }
  if(is.null(chr_ticknames)){
    if(get_chr_lengths_from_data){
    chrs <- names(chr_map)
    numeric_chrs <- chrs[grepl('^-?[0-9.]+$', chrs)] %>% as.numeric() %>% sort()
    non_numeric_chrs <- chrs[!grepl('^-?[0-9.]+$', chrs)]
    chr_order <- append(c(numeric_chrs), c(non_numeric_chrs))
    if(is.null(hide_chrticks_to_pos))
      hide_chrticks_to_pos <- length(numeric_chrs)
    chr_ticknames <- chr_order
  
    if(length(numeric_chrs) > hide_chrticks_from_pos){
      if(! show_all_chrticks){
        hide_chr <- numeric_chrs[seq(hide_chrticks_from_pos, hide_chrticks_to_pos, hide_every_nth_chrtick)]
        chr_ticknames[(chr_ticknames %in% hide_chr) == TRUE] <- ""
      }
      else{
        chr_ticknames <- chr_order
      }
    }
    ticknames <- chr_ticknames
    }
    else{
      ticknames <- c(1:16, '',18, '',20, '',22, 'X')
    }
  }
 tickpos <-chr_lengths_and_offsets %>% dplyr::group_by(CHROM)%>%
    dplyr::summarize(pm=offset+(m/2))%>%
    dplyr::pull(pm)
  names(tickpos) <- NULL
  return(list(names=ticknames, pos=tickpos))
}

get_pos_with_offset4list <- function(dat, offsets){
  for(i in seq_along(dat)){
    dat[[i]] <- get_pos_with_offset(dat[[i]], offsets)
  }
  return(dat)
}

get_pos_with_offset <- function(df,offsets){
  df$POS_orig <- df$POS
  df <- df %>% dplyr::mutate(POS=POS_orig+offsets[CHROM])
  return(df)
}


#' Get the index/lead variants
#'
#' @description
#'
#' \code{get_lead_snps()} Get the top variants within 1 MB windows of the genome with association p-values below the given threshold 
#'
#'
#' @param df Dataframe, GWAS summary statistics
#' @param genome_wide_thresh A number. P-value threshold for genome wide significant loci (5e-08 by default)
#' @param suggestive_thresh A number. P-value threshold for suggestive loci (1e-06 by default)
#' @param flank_size A number (default = 1e6). The size of the flanking region for the significant and suggestitve snps.
#' @param region_size A number (default = 1e6). The size of the region for top snp search. Only one snp per region is returned.
#' @return List of genome wide and suggestive loci.
#' @export
#' @examples
#' \dontrun{
#' get_sign_and_sugg_loci(CD_UKBB)
#' }
#'

get_sign_and_sugg_loci <- function(df, genome_wide_thresh = 5e-8, suggestive_thresh = 1e-6, flank_size = 1e6, region_size = 1e6) {
  genome_wide_snps <- data.frame()
  suggestive_snps <- data.frame()
  leads <- df |> get_lead_snps(thresh = suggestive_thresh, region_size = region_size, verbose = FALSE)
   if (nrow(leads) == 0) {
    return(list(genome_wide_snps = genome_wide_snps, suggestive_snps = suggestive_snps))
  }
  genome_wide <- leads |> filter(P < genome_wide_thresh)
  suggestive <- leads |> filter(P < suggestive_thresh & P >= genome_wide_thresh)
  if (nrow(genome_wide) != 0) {
    for (i in 1:nrow(genome_wide)) {
      genome_wide_snps <- bind_rows(genome_wide_snps, df |>
                                      filter(CHROM == genome_wide$CHROM[i] & POS >= genome_wide$POS[i] - (flank_size/2) & POS <= genome_wide$POS[i] + (flank_size/2))) |>
        distinct()
    }
  }
  if (nrow(suggestive) != 0) {
    # remove suggestive that are also genome wide snps
    suggestive <- suggestive |> anti_join(genome_wide, by = c("CHROM", "POS"))
    if (nrow(suggestive) != 0) {
      for (i in 1:nrow(suggestive)) {
        suggestive_snps <- bind_rows(suggestive_snps, df |>
                                       filter(CHROM == suggestive$CHROM[i] & POS >= suggestive$POS[i] - (flank_size/2) & POS <= suggestive$POS[i] + (flank_size/2))) |>
          distinct()
      }
    }
  }
  return(list(genome_wide_snps = genome_wide_snps, suggestive_snps = suggestive_snps))
}


#' Get the index/lead variants
#'
#' @description
#'
#' \code{get_lead_snps()} Get the top variants within 1 MB windows of the genome with association p-values below the given threshold 
#'
#'
#' @param df Dataframe
#' @param thresh A number. P-value threshold, only extract variants with p-values below this threshold (5e-08 by default)
#' @param protein_coding_only Logical, set this variable to TRUE to only use protein_coding genes for annotation
#' @param chr String, get the top variants from one chromosome only, e.g. chr="chr1"
#' @param .checked Logical, if the input data has already been checked, this can be set to TRUE so it wont be checked again (FALSE by default)
#' @param verbose Logical, set to TRUE to get printed information on number of SNPs extracted
#' @param keep_chr Logical, set to FALSE to remove the "chr" prefix before each chromosome if present (TRUE by default) 
#' @return Dataframe of lead variants. Returns the best variant per MB (by default, change the region size with the region argument) with p-values below the input threshold (thresh=5e-08 by default)
#' @export
#' @inheritParams regionplot
#' @examples
#' \dontrun{
#' get_lead_snps(CD_UKBB)
#' }
#'
get_lead_snps <- function(df, thresh=5e-08,region_size=1000000,protein_coding_only=FALSE,chr=NULL, .checked=FALSE, verbose=NULL, keep_chr=TRUE){
  variants <- df[0,]
  dat <- df
  if(is.data.frame(dat)) dat <- list(dat)
  chrPrefix=0
  
  dat[[1]] <- dat_column_chr_pos_check(dat[[1]]) 
  
  if("CHROM"  %in% colnames(dat[[1]])){
    if(!is.integer(dat[[1]][1,"CHROM"])){chrPrefix=1}
  }
  if(! is.numeric(region_size)){
    region_size <- convert_region_size(region_size)
  }
  if(! .checked){
    dat <- dat_check(dat, verbose=verbose)
  }

  df <- dat[[1]]
  if(! is.null(chr)){
    chr <- gsub("chr","", chr)
    df <- df %>% dplyr::filter(CHROM == chr)
  }
  
  df <- df %>% dplyr::filter(P<thresh)
  if(protein_coding_only & ("biotype" %in% colnames(df))){
    df <- df %>% dplyr::filter(biotype == "protein_coding")
  }
  if(nrow(df) > 0){
  	lead_snps <- do.call(rbind,
  		lapply(split(df, df$CHROM), function (df_by_chr) {
  			res <- data.frame()
  			df_by_chr <- dplyr::arrange(df_by_chr, P)
  			while (nrow(df_by_chr) > 0) {
  				lead_snp <- dplyr::slice(df_by_chr, 1)
  				res <- dplyr::bind_rows(res, lead_snp)
  				df_by_chr <- dplyr::filter(df_by_chr, abs(POS - lead_snp$POS) > region_size / 2)
  			}
  			res
  		}))
    variants <- lead_snps %>% dplyr::distinct(CHROM, POS, .keep_all = T)
    variants$color <-  dat[[1]][1,"color"]
    if(! is.null(verbose)){
      if(verbose){
        print(paste("Found ",length(variants$POS), " index/lead variants with a p-value below ", thresh, sep=""))
        print(paste("Index/lead variant: the top variant within a",format(region_size, scientific = F),"bp region_size"), sep="")
      }
    }
  }else{
    if(is.null(verbose)){
      print(paste("There are no SNPs with p-values below ",thresh, " in the input dataset. Use the [thresh] argument to lower the threshold.",sep=""))
    }else if(verbose){
      print(paste("There are no SNPs with p-values below ",thresh, " in the input dataset. Use the [thresh] argument to lower the threshold.",sep=""))
    }
    
  }
  if("tmp" %in% colnames(variants)){
    variants <- variants %>% dplyr::select(-tmp)
  }
  if(nrow(variants) > 0){
    if(keep_chr & chrPrefix){
      variants$CHROM <- gsub("(chr|CHR|Chr)","", variants$CHROM)
      variants$CHROM  <- paste0("chr", variants$CHROM)
    }
  }
  return(variants)
}


#' Get the genetic position of a gene by its gene name
#'
#' @description
#'
#' \code{get_genes_by_Gene_Symbol()} Get genes by their gene symbol/name
#' Required parameters is on gene name or a vector of gene names
#'
#' @param genes A string or vector of strings representing gene names, (e.g. "FTO") or  (c("FTO","NOD2"))
#' @param chr A string, search for the genes on this chromosome only, (e.g chr="chr1")
#' @param build A string, genome build, choose between builds 37 (GRCh37) and 38 (GRCh38) (default is 38)
#' @return Dataframe of genes
#' @export
#'
#' @examples
#' \dontrun{
#'   get_genes_by_Gene_Symbol(c("FTO","THADA"))
#' }
#'
get_genes_by_Gene_Symbol <- function(genes, chr=NULL, build=38){
  genes_df <- get_db(build) %>% dplyr::filter(gene_symbol %in% genes) 
  if(! is.null(chr)){
    chr <- gsub('chr','',chr)
    genes_df <- genes_df %>% dplyr::filter(chrom == paste("chr",chr,sep=""))
  }
  genes_df <- genes_df %>% dplyr::mutate(POS = gene_start + round((gene_end-gene_start)/2)) %>% dplyr::rename(Gene_Symbol=gene_symbol,CHROM=chrom)
  dist_genes <- genes_df %>% dplyr::distinct(CHROM,gene_start,gene_end, .keep_all = T)
  return(dist_genes)
}


#' Get the genetic position of a gene by gene name
#'
#' @description
#'
#' \code{get_gene_coords()} Get the gene coordinates for a gene
#' Required parameter is gene name
#'
#' @param gene_name A string representing a gene name (e.g. "FTO")
#' @param chr A string, search for the genes on this chromosome only, (e.g chr="chr1")
#' @param build A string, genome build, choose between builds 37 (GRCh37) and 38 (GRCh38) (default is 38)
#' @return Dataframe with the gene name and its genetic coordinates
#' @export
#'
#' @examples
#' \dontrun{
#' get_gene_coords("FTO")
#' }
#'

get_gene_coords  <- function(gene_name,chr=NULL, build=38){
  gene <- get_db(build) %>% dplyr::filter(gene_symbol == gene_name) %>% dplyr::select(-exon_chromstart,-exon_chromend)
  if(! is.null(chr)){
    chr <- gsub("chr", "", chr)
    chr <- paste("chr",chr,sep="")
    gene <- gene  %>% dplyr::filter(chrom == chr) 
  }
  if(is.null(gene)){
    print(paste("Could not find a gene with the gene name: [", gene_name, "] in build ",build, sep=""))
  }
  return(gene)
}

get_legend<-function(p1){
  tmp <- ggplot_gtable(ggplot_build(p1))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}



#' Get the top hit from the dataframe
#'
#' @description
#'
#' \code{get_top_snp()} Get the top hit from the dataframe
#' All other input parameters are optional
#'
#' @param df Dataframe containing association results
#' @param chr String, get the top hit in the data frame for this chromosome. If chromosome is not provided, the top hit from the entire dataset is returned.

#' @return Dataframe containing the top hit
#' @export
#'
#' @examples
#' \dontrun{
#' get_top_snp(CD_UKBB, chr="chr1")
#' }
#'
get_top_snp <- function(df, chr=NULL){
  if (!is.null(chr)) {
    chr_tmp <- gsub('chr','',chr)
    chr <- paste("chr",chr_tmp, sep="")
    df <- df %>%
      filter(CHROM == chr)
  } else {
    print("Returning the top hit over the entire genome, since chromosome was not provided as an argument")
  }
  top_hit <- df %>%
    dplyr::arrange(P) %>%
    head(n = 1)

  return(top_hit)
}


#' Get the top hit from the dataframe
#'
#' @description
#'
#' \code{get_topr_colors()} Get the top hit from the dataframe
#' All other input parameters are optional
#'
#' @return Vector of colors used for plotting
#' @export
#'
#' @examples
#' \dontrun{
#' get_topr_colors()
#' }
#'
get_topr_colors <- function(){
  return(c("darkblue","#E69F00","#00AFBB","#999999","#FC4E07","darkorange1","darkgreen","blue","red","magenta","skyblue","grey40","grey60","yellow","black","purple","orange","pink","green","cyan"))
}

set_genes_pos_adj <- function(genes, offsets){
  #CHROM,POS,Gene_Symbol
  genes <- genes %>% dplyr::mutate(CHROM=gsub('chr','',CHROM))
  genes[genes$CHROM=='X', 'CHROM'] <- "23"
  genes$CHROM <- as.integer(genes$CHROM)
  genes <- genes %>% dplyr::mutate(pos_adj=POS+offsets[CHROM])
  return(genes)
}

#' Get SNPs/variants within region
#'
#' @description
#'
#' \code{get_snps_within_region()}
#'
#' @param df data frame of association results with the columns CHR and POS
#' @param region A string representing the genetic region (e.g chr16:50693587-50734041)
#' @param chr A string, chromosome (e.g. chr16)
#' @param xmin An integer, include variants with POS larger than xmin
#' @param xmax An integer, include variants with POS smaller than xmax
#' @param keep_chr Deprecated: Logical, set to FALSE to remove the "chr" prefix before each chromosome if present (TRUE by default) 
#' @return the variants within the requested region
#' @export
#'
#' @examples
#' \dontrun{
#' get_snps_within_region(CD_UKBB, "chr16:50593587-50834041")
#' }
#'

get_snps_within_region <- function(df, region, chr=NULL, xmin=NULL, xmax=NULL,keep_chr=NULL){
  snps <- NULL
  if (!missing(keep_chr)) deprecated_argument_msg(keep_chr)
  df <- dat_column_chr_pos_check(df)
  if(!is.null(region)){
    tmp <- unlist(stringr::str_split(region, ":"))
    chr <- tmp[1]
    tmp_pos <- unlist(stringr::str_split(tmp[2], "-"))
    xmin <- as.numeric(tmp_pos[1])
    xmax <- as.numeric(tmp_pos[2])
  }
  if(!is.null(chr) & !is.null(xmin) & !is.null(xmax)){
    snps <- df %>% filter(CHROM == chr & POS >= xmin & POS <= xmax)
    if(length(snps$POS) < 1){
      print(paste("There are no SNPs within the region: ", chr, ":", xmin, "-", xmax, sep=""))
    }
  }
  return(snps)
}

get_chrs_from_data = function(dat){
  all_chrs=NULL
  for(i in seq_along(dat)){
    unique_chrs=unique(dat[[i]]$CHROM)
    all_chrs <- c(all_chrs, unique_chrs)
  }
  chrs <- unique(all_chrs) %>% sort()
  return(chrs)
}


get_max_value_by_chr_from_data = function(dat, chrs){
  max_chr_values=c()
  for(i in 1:(length(chrs))){
    max_chr_val=0
    for(j in seq_along(dat)){ #for(j in seq_along(dat)){
      dat_chr <- dat[[j]] %>% dplyr::filter(CHROM==chrs[i])
      if(nrow(dat_chr)> 0){
        max_val <- max(dat_chr$POS, na.rm = T)
        if(max_val > max_chr_val){
          max_chr_val <- max_val  
        }
      }
    }
    max_chr_values[i] <- max_chr_val*1.02
  }
  chr_lengths <- data.frame("CHROM" = unique(chrs), "V2" = max_chr_values)

  return(chr_lengths)
}


