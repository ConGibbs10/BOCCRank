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

# get working directory
getwd()

# set seed
set.seed(seed)

# fix files
write_tune_from_msgs(
  array_path = paste0('data-raw/tune/', year, '/array/'),
  msgs_path = paste0('data-raw/tune/', year, '/msgs/')
)
