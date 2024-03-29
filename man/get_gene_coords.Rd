% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/setters_and_getters.R
\name{get_gene_coords}
\alias{get_gene_coords}
\title{Get the genetic position of a gene by gene name}
\usage{
get_gene_coords(gene_name, chr = NULL, build = 38)
}
\arguments{
\item{gene_name}{A string representing a gene name (e.g. "FTO")}

\item{chr}{A string, search for the genes on this chromosome only, (e.g chr="chr1")}

\item{build}{A string, genome build, choose between builds 37 (GRCh37) and 38 (GRCh38) (default is 38)}
}
\value{
Dataframe with the gene name and its genetic coordinates
}
\description{
\code{get_gene_coords()} Get the gene coordinates for a gene
Required parameter is gene name
}
\examples{
\dontrun{
get_gene_coords("FTO")
}

}
