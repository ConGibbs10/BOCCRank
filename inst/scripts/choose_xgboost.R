# OPTIONS:
#- year (character): year in YYYY format
#- seed (integer): seed for reproducibility

library(LPCTA)

# allow debugging
options(echo = TRUE)

# parse arguments
args <- R.utils::commandArgs(trailingOnly = FALSE, asValues = TRUE)
year <- as.character(args$year)
seed <- as.integer(args$seed)

# get number of cores
wkrs <- length(future::availableWorkers())

# set seed
set.seed(seed)

# read and prepare the cluster features
fp <- file.path('data-raw', 'features', year)
clf <-
  read_features(fp, pattern = 'paris.', recursive = FALSE)
clf <- prepare_features(
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

# read the tune results
tune_files <- list.files(paste0('data-raw/tune/', year, '/array'), full.names = TRUE)
tune_results <- purrr::map_dfr(tune_files, ~suppressMessages(readr::read_tsv(.x)))
tune_results <- dplyr::arrange(tune_results, test_rmse_mean)

# tune the dart booster
dart.param <-
  list(
    booster = "dart",
    objective = "reg:logistic",
    eval_metric = "rmse",
    nthread = wkrs,
    max_depth = tune_results$tree_depth[1],
    eta = tune_results$eta[1],
    gamma = tune_results$gamma[1],
    subsample = tune_results$subsample[1],
    rate_drop = tune_results$rate_drop[1],
    skip_drop = tune_results$skip_drop[1]
  )
xgb <- xgboost::xgboost(
  params = dart.param,
  nrounds = tune_results$iter[1],
  data = as.matrix(clf[, -1]),
  label = clf$snowballing_pvalue
)

# write result
trname <- file.path('data-raw', 'tune', paste0('tune_grid_', year, '.tsv'))
mname <- file.path('data-raw', 'tune', paste0('xgb_model_', year, '.model'))
readr::write_tsv(tune_results, file = trname)
xgboost::xgb.save(xgb, fname = mname)
