#' Filter a list of clusters to include only non-trivial instances.
#'
#' @param loc List of clusters
#'
#' @return A subset list of clusters which contain at least one gene, one phenotype, and three members.
#' @export
filter_clusters <- function(loc) {
  if (length(loc) == 2 &&
      all(purrr::map2_lgl(names(loc), c('IDs', 'clusters'), function(x, y)
        x == y))) {
    lgl <- purrr::map_lgl(loc$clusters,
                          function(x)
                            length(x) >= 3 &&
                            any(stringr::str_sub(x, 1, 3) == 'HP:') &&
                            any(stringr::str_sub(x, 1, 3) != 'HP:'))
    res <- list(IDs = loc$IDs[lgl], clusters = loc$clusters[lgl])
  } else {
    res <- purrr::keep(loc,
                       function(x)
                         length(x) >= 3 &&
                         any(stringr::str_sub(x, 1, 3) == 'HP:') &&
                         any(stringr::str_sub(x, 1, 3) != 'HP:'))
  }

  return(res)
}
