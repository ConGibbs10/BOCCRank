# OPTIONS:
#- year (character): year in YYYY format
#- seed (integer): seed for reproducibility
#- nreps (integer): number of iterations considered

library(LPCTA)

# allow debugging
options(echo = TRUE)

# parse arguments
args <- R.utils::commandArgs(trailingOnly = FALSE, asValues = TRUE)
year <- as.character(args$year)
seed <- as.integer(args$seed)
nreps <- as.integer(args$nreps)

# set seed
set.seed(seed)

# path to node list
nl <- paste0('data-raw/edgelists/', year, '/String_HPO_', year, '.phenotypic_branch.nodenames.txt')
nl <- readr::read_delim(nl, delim = '\t', col_names = FALSE)

# compute the modularity matrix
mname <- paste0('data-raw/zcmod/', year, '/modularity_matrix.mtx')
M <- Matrix::readMM(mname)
M <- as.matrix(M) # make it dense to avoid errors.

# get membership from 5 runs of ZCmod
mship <- vector('list', length = nreps)
for(j in 1:nreps) {
  cat('Membership---', j, ':', nreps, '\n')
  # get membership from louvain
  mship[[j]] <- ECoHeN::genlouvain(M)
  mship[[j]] <- as.vector(mship[[j]])
}
mship <- purrr::discard(mship, function(x) is.null(x))
fname <- paste0('data-raw/zcmod/', year, '/membership_seed', seed, '_nreps', nreps, '.txt')
write_ragged_tsv(mship, fname)

# get rows and columns of nonzero entries for sparse matrix
M <- Matrix::Matrix(unlist(M))
mship_mod <- vector('double', length = length(mship))
for(j in 1:length(mship)) {
  cat('Modularity---', j, ':', length(mship), '\n')
  max_m <- max(mship[[j]])
  # get rows and columns of non-zero elements
  row <- purrr::reduce(purrr::map(1:max_m, function(k) which(mship[[j]] == k)), c)
  col <- sort(mship[[j]])
  # set up affinity matrix
  B <- Matrix::sparseMatrix(i = row, j = col, x = 1)
  mship_mod[j] <- (1/4)*sum(Matrix::diag(Matrix::t(B)%*%M%*%B))
}
fname <- paste0('data-raw/zcmod/', year, '/modularity_seed', seed, '_nreps', nreps, '.txt')
write_ragged_tsv(mship_mod, fname)

# overwrite mship to be only the one with maximum modularity
max_mod <- which.max(mship_mod)
mship <- mship[[max_mod]]
mship_max <- max(mship)

# write community
vnames <- nl$X2
comm <- vector('list', length = mship_max)
for(i in 1:mship_max) {
  comm[[i]] <- vnames[which(mship == i)]
}
fname <- paste0('data-raw/clusters/', year, '/zcmod.', year, '.coms.txt')
write_ragged_tsv(comm, fname)
