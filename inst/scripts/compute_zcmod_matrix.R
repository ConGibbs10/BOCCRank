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

# set seed
set.seed(seed)

# compute the modularity matrix
G <- read_network(path = 'data-raw/edgelists/', year = year)
mm <- ECoHeN::compute_ZCMod_matrix(G = G, node_type = 'gene')

# write results
fname <- file.path('data-raw', 'zcmod', year, paste0('modularity_matrix.mtx'))
Matrix::writeMM(mm, file = fname)
