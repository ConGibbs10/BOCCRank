# OPTIONS:
#- index (integer): array index
#- year (character): year in YYYY format
#- nreps (integer): number of replicates for tune
#- seed (integer): seed for reproducibility

library(BOCCRank)

# allow debugging
options(echo = TRUE)

# parse arguments
args <- R.utils::commandArgs(trailingOnly = FALSE, asValues = TRUE)
index <- as.integer(args$index)
year <- as.character(args$year)
nreps <- as.integer(args$nreps)
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

# prepare grid of parameters
xgboost_params <- dials::parameters(
  nrounds = dials::trees(),
  eta = dials::learn_rate(),
  gamma = dials::loss_reduction(),
  dials::tree_depth(),
  subsample = dials::sample_prop(),
  rate_drop = dials::dropout(),
  skip_drop = dials::dropout()
)
xgboost_params <-
  dials::grid_max_entropy(xgboost_params, size = nreps)

# tune the dart booster
dart.param <-
  list(
    booster = "dart",
    objective = "reg:logistic",
    eval_metric = "rmse",
    nthread = wkrs,
    max_depth = xgboost_params$tree_depth[index],
    eta = xgboost_params$eta[index],
    gamma = xgboost_params$gamma[index],
    subsample = xgboost_params$subsample[index],
    rate_drop = xgboost_params$rate_drop[index],
    skip_drop = xgboost_params$skip_drop[index]
  )
dart.cv <- xgboost::xgb.cv(
  params = dart.param,
  nrounds = xgboost_params$nrounds[index],
  data = as.matrix(clf[, -1]),
  nfold = 5,
  label = clf$snowballing_pvalue,
  early_stopping_rounds = 50
)
hgrid <-
  dplyr::bind_cols(xgboost_params[index, ], dart.cv$evaluation_log[dart.cv$best_iteration, ], best_iter = dart.cv$best_iteration)

# write result
fname <- file.path('data-raw', 'tune', year, 'array', paste0('tune_', index, '.tsv'))
readr::write_tsv(hgrid, file = fname)
