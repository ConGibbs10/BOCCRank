#' Read and format features for XGBoost
#'
#' @param year Year of features in YYYY.
#'
#' @return Numeric matrix.
#' @export
read_xgb_features <- function(year) {
  fp <- file.path('data-raw', 'features', year)
  clf <-
    read_features(fp, pattern = 'paris.', recursive = FALSE)
  clf <- suppressMessages(
    prepare_features(
      clf,
      feature_map = feature_map,
      category = c('response', 'bio', 'net'),
      type = 'list',
      exclusions = c(
        'mg2_pairs_count',
        'mg2_not_pairs_count',
        'mg2_portion_families_recovered',
        'cluster_origin',
        'bocc_origin',
        'cluster_method',
        'subcluster_method',
        'year',
        'IDs',
        'go_sig_threshold',
        'num_new_edges_on_any_node',
        'HPO_ratio'
      ),
      verbose = TRUE
    )
  )

  return(as.matrix(clf))
}
