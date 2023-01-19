devtools::load_all()

# allow debugging
options(echo = TRUE)

# set up parallel
wkrs <- length(future::availableWorkers())
future::plan('multisession', workers = wkrs)

# 2019 - 2020
## get nontrivial clusters
cl <- read_clusters(path = 'data-raw/subclusters/2019', pattern = 'paris.*', names = FALSE)
fcl <- purrr::map(cl, filter_clusters)
fcl <- unlist(fcl, recursive = FALSE)
new_edges <- get_new_edges(KG19, KG20)
df <- as.data.frame(new_edges)
names(df) <- c('gene', 'phenotype')

## check if new edges occur in cluster
in_cluster <-
  furrr::future_map_lgl(1:nrow(new_edges),
           function(x) any(purrr::map_lgl(fcl, ~new_edges[x, 1] %in% .x) &
                             purrr::map_lgl(fcl, ~new_edges[x, 2] %in% .x)))
df$in_cluster <- in_cluster

## write in cluster
readr::write_tsv(df, 'data-raw/edge_containment/new_edges_19_20.tsv')

# 2020 - 2021
## get nontrivial clusters
cl <- read_clusters(path = 'data-raw/subclusters/2020', pattern = 'paris.*', names = FALSE)
fcl <- purrr::map(cl, filter_clusters)
fcl <- unlist(fcl, recursive = FALSE)
new_edges <- get_new_edges(KG20, KG21)
df <- as.data.frame(new_edges)
names(df) <- c('gene', 'phenotype')

## check if new edges occur in cluster
in_cluster <-
  furrr::future_map_lgl(1:nrow(new_edges),
                        function(x) any(purrr::map_lgl(fcl, ~new_edges[x, 1] %in% .x) &
                                          purrr::map_lgl(fcl, ~new_edges[x, 2] %in% .x)))
df$in_cluster <- in_cluster

## write in cluster
readr::write_tsv(df, 'data-raw/edge_containment/new_edges_20_21.tsv')
