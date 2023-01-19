# length of grid and seed
ngrid <- 100
seed <- 6262
set.seed(seed)

# parameters to tune
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
  dials::grid_max_entropy(xgboost_params, size = ngrid)
tune_grid <- xgboost_params

# write data
usethis::use_data(tune_grid, overwrite = TRUE)
