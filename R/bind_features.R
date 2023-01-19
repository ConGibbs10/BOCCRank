#' Bind rows of feature list.
#'
#' @param feature_list List of features.
#'
#' @keywords internal
#'
#' @return A data frame of features.
#' @export
bind_features <- function(feature_list) {
  # get needed data
  bocc_types <-
    purrr::map(feature_list, function(df)
      purrr::map_chr(df, typeof))
  pairs <-
    data.frame(RcppAlgos::comboGeneral(v = 1:length(bocc_types), m = 2))
  same_types <-
    purrr::pmap_lgl(pairs, function(X1, X2)
      identical(bocc_types[[X1]], bocc_types[[X2]]))
  same_names <- purrr::pmap_lgl(pairs, function(X1, X2)
    identical(names(bocc_types[[X1]]), names(bocc_types[[X2]])))

  # bind accordingly
  if (all(same_types) && all(same_names)) {
    res <- dplyr::bind_rows(feature_list)
  }
  else {
    if (all(same_names)) {
      col_is_list <- bocc_types %>%
        purrr::transpose() %>%
        purrr::map_lgl(., ~ any(.x == 'list'))
      res <- feature_list %>%
        purrr::map2_dfr(., bocc_types, function(bocc, type) {
          tolistify <-
            setdiff(names(col_is_list)[col_is_list], names(type)[col_is_list])
          dplyr::mutate(bocc, dplyr::across(dplyr::all_of(tolistify), ~
                                              list(.x)))
        })
    }
    else {
      stop('Columns of BOCC results differ across files.')
    }
  }

  return(res)
}
