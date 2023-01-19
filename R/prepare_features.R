#' Prepare the columns of a data frame based on a covariate map.
#'
#' @param dt Data frame.
#' @param feature_map List representing feature map with name, category, and type elements.
#' @param category Vector describing the order to sort the feature categories.
#' @param type Data types to exclude.
#' @param exclusions Vector of column names to exclude, regardless.
#' @param verbose Print final removals?
#'
#' @return Data frame
#' @export
prepare_features <- function(dt, feature_map, category, type = c(), exclusions = c(), verbose = TRUE) {
  # get feature names and compare with expected
  nms <- names(dt)
  if(length(nms) != length(feature_map$name) || !all(sort(nms) == sort(feature_map$name))) {
    vabs <- sort(setdiff(nms, feature_map$name))
    warning('There are features present yet excluded from the feature map. \n', immediate. = TRUE)
    cat('c(', paste0(purrr::map_chr(vabs, ~stringr::str_c("'", .x, "'")), collapse = ', '), ')\n\n', sep = '')
    cat('\n')
  }
  if(!all(names(feature_map) %in% c('name', 'category', 'type'))) {
    stop('Feature map does not have a name, category, and type element.')
  }
  if(!all(category %in% unique(feature_map$category))) {
    stop('Category vector does not correspond to feature map.')
  }

  # filter out fully (dis)connected clusters
  fdt <-
    dplyr::filter(dt,!((cluster_size - 1) == avg_internal_degree |
                         avg_internal_degree == 0
    ))
  if(verbose && nrow(fdt) < nrow(dt)) {
    message('Removed ', nrow(dt) - nrow(fdt), ' fully connected clusters.')
    clrm <- suppressMessages(dplyr::anti_join(dt, fdt))
    clrm <- dplyr::select(clrm, dplyr::any_of(c('year', 'cluster_method', 'subcluster_method', 'IDs', 'cluster_size', 'avg_internal_degree')))
  }
  dt <- fdt

  # remove type exclusions
  if(length(type) > 0) {
    dt <- dplyr::select(dt, -dplyr::any_of(feature_map$name[feature_map$type %in% type]))
  }

  # sort based on category vector
  pcs <- category %>%
    purrr::imap(., function(v, i) {
      vcat <- feature_map$name[feature_map$category == v]
      if(category[i] == 'id') vcat else sort(vcat)
    }) %>%
    purrr::flatten_chr()
  dt <- dplyr::select(dt, dplyr::any_of(pcs), dplyr::everything())

  # remove exclusions
  if(length(exclusions) > 0) {
    dt <- dplyr::select(dt, -dplyr::any_of(exclusions))
  }

  # print
  if(verbose) {
    vrm <- sort(setdiff(nms, names(dt)))
    message('Removed ', length(vrm), ' variables.')
    cat('c(', paste0(purrr::map_chr(vrm, ~stringr::str_c("'", .x, "'")), collapse = ', '), ')\n\n', sep = '')
  }

  return(dt)
}
