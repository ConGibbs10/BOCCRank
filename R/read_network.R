#' Read biological network.
#'
#' @details Reads biological network from path to edgelists and year.
#'
#' @param path Path to edgelists.
#' @param year Year in YYYY format.
#'
#' @return An igraph object.
#' @export
read_network <- function(path, year) {
  el <- paste0(path, year, '/String_HPO_', year, '.phenotypic_branch.numbered.edgelist.txt')
  nl <- paste0(path, year, '/String_HPO_', year, '.phenotypic_branch.nodenames.txt')
  nattrl <- paste0(path, year, '/String_HPO_', year, '.phenotypic_branch.nodeattributes.txt')
  G <- read_KG(edgelist = el, nodes = nl, node_attrs = nattrl)

  return(G)
}
