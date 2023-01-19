#' Reads a community files (either cluster or subcluster) as a list.
#'
#' @param file Text file where each row provides community memebers/
#'
#' @return A list where each element is a community.
#' @export
#'
#' @examples
#' \dontrun{
#' read_cluster(file = 'data-raw/subclusters/2021/paris.greedy.2021.coms.txt', names = TRUE)
#' }
read_cluster <- function(file, names = FALSE) {
  cluster_delim <- suppressMessages(suppressWarnings(
    file %>%
      readr::read_delim(., delim = ' ', col_names = FALSE) %>%
      dplyr::pull(., X1)
  ))
  cluster <- cluster_delim %>%
    purrr::map(., function(c)
      c %>%
        stringr::str_split(., pattern = "\\t", simplify = TRUE) %>%
        as.vector() %>%
        .[-1])
  if (names) {
    cluster_names <- cluster_delim %>%
      purrr::map_chr(., function(c)
        c %>%
          stringr::str_split(., pattern = "\\t", simplify = TRUE) %>%
          as.vector() %>%
          .[1])
    res <- list(IDs = cluster_names, clusters = cluster)
  } else{
    res <- cluster
  }

  return(res)
}
