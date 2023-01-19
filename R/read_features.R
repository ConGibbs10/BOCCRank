#' Reads a set of files containing cluster features as a data frame.
#'
#' @param path String specifying where to look for all the community files.
#' @param pattern Regex pattern for which communities to pull.
#' @param recursive Logical specifying whether to recursively pull community files.
#'
#' @return A list where each element is a community.
#' @export
#' @examples
#' read_features(
#'  path = 'data-raw/features/2021',
#'  pattern = '*',
#'  recursive = FALSE
#' )
read_features <-
  function(path,
           pattern = '*',
           recursive = FALSE) {
    cf <-
      list.files(
        path = path,
        pattern = pattern,
        recursive = recursive,
        full.names = TRUE
      )
    # features
    bocc <- cf %>%
      furrr::future_map(., function(x) read_feature(x)) %>%
      bind_features()

    return(bocc)
  }
