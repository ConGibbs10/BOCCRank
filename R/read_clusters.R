#' Reads a set of community files (either clusters or subclusters) as a list.
#'
#' @param path String specifying where to look for all the community files.
#' @param pattern Regex pattern for which communities to pull.
#' @param recursive Logical specifying whether to recursively pull community files.
#'
#' @return A list where each element is a community.
#' @export
#'
#' @examples
#' \dontrun{
#' read_clusters(
#'  path = 'data-raw/subclusters/2021/',
#'  pattern = 'paris.',
#'  recursive = FALSE,
#'  names = TRUE,
#'  long = FALSE
#' )
#' }
read_clusters <-
  function(path,
           pattern = '*',
           recursive = FALSE,
           names = FALSE,
           long = FALSE) {
    # change names to TRUE if long is requested
    if(long) {
      names <- TRUE
    }
    # read files from path
    cf <-
      list.files(
        path = path,
        pattern = pattern,
        recursive = recursive,
        full.names = TRUE
      )
    # get abbreviations
    cf_abbr <-
      list.files(
        path = path,
        pattern = pattern,
        recursive = recursive,
        full.names = FALSE
      )
    # get names
    nms <- purrr::map2_chr(cf_abbr,
                           stringr::str_c('.', tools::file_ext(cf_abbr)),
                           function(x, y)
                             stringr::str_remove(x, y))
    # read clusters
    clusters <- suppressMessages(suppressWarnings(
      cf %>%
        purrr::map(., function(x)
          read_cluster(x, names = names)) %>%
        purrr::set_names(., nms)
    ))
    # convert to long if requested
    if (names && long) {
      fnms <- names(clusters)
      nms <- purrr::map(clusters, function(x) x$IDs)
      clusters <- purrr::map(clusters, function(x) x$clusters)

      res <- vector(mode = 'list', length = length(fnms))
      for (i in seq_along(fnms)) {
        res[[i]] <-
          purrr::map2_dfr(clusters[[i]],
                          nms[[i]],
                          ~ data.frame(
                            method = fnms[[i]],
                            clusterID = .y,
                            nodeID = .x
                          ))
      }
      clusters <- dplyr::bind_rows(res)
    }

    return(clusters)
  }
