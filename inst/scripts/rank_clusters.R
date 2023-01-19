# OPTIONS:
#- year (character): year in YYYY format
#- seed (integer): seed for reproducibility

library(BOCCRank)

# allow debugging
options(echo = TRUE)

# parse arguments
args <- R.utils::commandArgs(trailingOnly = FALSE, asValues = TRUE)
year <- as.character(args$year)
seed <- as.integer(args$seed)

# set seed
set.seed(seed)

# read the model
xgb <- xgboost::xgb.load(paste0('data-raw/tune/', 'xgb_model_', year, '.model'))

# read out of sample data
year_t1 <- as.character(as.integer(year) + 1)

# read the data without identifiers
fp <- file.path('data-raw', 'features', year_t1)
clf <-
  read_features(fp, pattern = 'paris.', recursive = FALSE)
X <- prepare_features(
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
X <- dplyr::select(X, -dplyr::any_of(c('snowballing_pvalue')))

# read the data with identifiers
IDs <- prepare_features(
  clf,
  feature_map = feature_map,
  category = c('id'),
  type = 'list',
  exclusions = c(
    'cluster_origin',
    'bocc_origin'
  ),
  verbose = TRUE
)
IDs <- IDs[,c('year', 'cluster_method', 'subcluster_method', 'IDs')]
IDs$clusterID <- paste0(IDs$subcluster_method, '.', IDs$cluster_method, '.', IDs$year, ':', IDs$IDs)

# fit the rankings
IDs$estimated_snowballing_pvalue <- predict(xgb, newdata = as.matrix(X))
IDs$rank <- rank(IDs$estimated_snowballing_pvalue, ties.method = 'random')
IDs <- IDs[,c('clusterID', 'estimated_snowballing_pvalue', 'rank')]

# save
readr::write_tsv(IDs, file = paste0('data-raw/rankings/xgb_cluster_rankings_', year_t1, '.tsv'))
