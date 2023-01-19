#' Convert edges to string.
#'
#' @param G igraph object
#'
#' @return Character vector.
#' @export
edges_to_string <- function(G) {
  x <- as.data.frame(igraph::get.edgelist(G))
  x <- swap_if(x, c('V1', 'V2'), c('V1', 'V2'))
  logi <-
    (stringr::str_sub(x$V1, 1, 3) == 'HP:' &
       stringr::str_sub(x$V2, 1, 3) != 'HP:') |
    (stringr::str_sub(x$V1, 1, 3) != 'HP:' &
       stringr::str_sub(x$V2, 1, 3) == 'HP:')
  x <- x[logi,]
  x <- do.call(paste, c(as.data.frame(x), sep = '|'))

  return(x)
}
