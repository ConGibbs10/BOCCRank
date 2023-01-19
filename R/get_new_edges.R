#' Get matrix of new edges.
#'
#' @param old_KG Old knowledge graph.
#' @param new_KG New knowledge graph.
#'
#' @return Character matrix.
#' @export
get_new_edges <- function(old_KG, new_KG) {
  # G2P subgraphs
  s_old <- igraph::subgraph.edges(old_KG, which(igraph::edge_attr(old_KG, name = 'type') == 'G2P'))
  s_new <- igraph::subgraph.edges(new_KG, which(igraph::edge_attr(new_KG, name = 'type') == 'G2P'))

  # get edges as string
  e_old <- edges_to_string(s_old)
  e_new <- edges_to_string(s_new)

  # get new edges and swap columns so it is gene then hpo
  e_changes <- setdiff(e_new, e_old)
  e_changes <- stringr::str_split(e_changes, pattern = '\\|', simplify = T)
  should_swap <- stringr::str_sub(e_changes[,1], 1, 3) == 'HP:'

  return(e_changes[should_swap, c(1, 2)] <- e_changes[should_swap, c(2, 1)])
}

