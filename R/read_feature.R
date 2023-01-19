#' Reads a file containing cluster features as a data frame.
#'
#' @param file Text file where cluster features are written.
#'
#' @return A data frame where each row represents a cluster
#' @export
#' @examples
#' \dontrun{
#' read_feature('data-raw/features/2021/paris.greedy.2021.bocc_res.tsv')
#' }
read_feature <- function(file) {
  # read in the file as a tsv
  result <-
    suppressMessages(suppressWarnings(readr::read_delim(
      file, delim = '\t', col_names = TRUE
    )))
  nms <- names(result)
  # save whether column is a list as a named vector
  col_is_list <-
    purrr::map_lgl(result, function(x)
      sum(stringr::str_detect(as.character(x), ','), na.rm = TRUE) > 0)

  # partition list items
  result_nonlist <- result[which(!col_is_list)]
  result_list <- result[which(col_is_list)]

  # convert list columns to lists
  convert_list <- list()
  for (i in 1:ncol(result_list)) {
    col <- result_list[[i]]
    convert_list[[i]] <-
      purrr::map(col,
                 function(x)
                   x %>%
                   stringr::str_split(., ',', simplify = TRUE) %>%
                   as.vector() %>%
                   type.convert(., as.is = TRUE))
  }
  names(convert_list) <- names(result_list)
  tbl <-
    dplyr::bind_cols(result_nonlist, dplyr::as_tibble(convert_list))
  tbl <- dplyr::select(tbl, tidyselect::any_of(nms))

  # add columns and rename
  methods_nms <- file %>%
    basename() %>%
    stringr::str_extract(., ".*?(?=\\.\\d\\d\\d\\d)") %>%
    stringr::str_split(., pattern = '\\.', simplify = TRUE) %>%
    as.vector()
  yr <- stringr::str_extract(file, pattern = '\\d\\d\\d\\d')
  if (length(methods_nms) != 2)
    stop('Could not parse clustering and subclustering names from file.')

  # make edits and return
  res <- tbl %>%
    dplyr::rename(., IDs = cluster_id) %>%
    tibble::add_column(
      .,
      bocc_origin = file,
      year = yr,
      cluster_method = methods_nms[2],
      subcluster_method = methods_nms[1],
      .before = 1
    ) %>%
    dplyr::mutate(
      .,
      cluster_origin = file.path(
        'data-raw',
        'subclusters',
        yr,
        stringr::str_c(subcluster_method, '.', cluster_method, '.', yr, '.coms.txt')
      ),
      .before = 1
    )

  # special considerations
  if (typeof(res$snowballing_pvalue) == 'character') {
    res$snowballing_pvalue <- NA_real_
  }
  if (typeof(res$num_new_edges_on_any_node) == 'character') {
    res$num_new_edges_on_any_node <- NA_real_
  }
  disease_lgl <-
    purrr::map_lgl(
      res$max_norm_disease_comma_sep_string,
      function(x) length(x) == 1 &&
        x == 'No Associated Disease'
    )
  res$max_norm_disease_comma_sep_string[disease_lgl] <-
    NA_character_

  return(res)
}
