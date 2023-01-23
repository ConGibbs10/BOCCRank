# allow debugging
options(echo = TRUE)

# get number of cores
wkrs <- length(future::availableWorkers())

seed <- 6262
set.seed(seed)

# function to simutate
sim_process <- function(geq = 3, rate = 1/40, window = 8, line = 8, eps = 1) {
  inter <- rexp(1000, rate = rate)
  arr <- cumsum(inter)
  arr <- arr[arr <= line]

  # total windows of time
  frame <- data.frame(start = seq(0, line/window, by = eps))
  frame$end <- frame$start + window
  frame <- frame[frame$end <= line,]

  n_crash <- purrr::map2_dbl(frame$start, frame$end, function(s, e) length(arr[arr >= s & arr < e]))

  return(any(n_crash >= geq))
}

# do simulations in parallel
future::plan('multisession', workers = wkrs)
B <- 100000

# compute one
f <- function(k) (((8/40)^k)/factorial(k))*exp(-8/40)
1-f(0)-f(1)-f(2)

# check one - estimated 0.00111
mean(
  furrr::future_map_lgl(1:B, function(x)
    sim_process(
      geq = 3,
      rate = 1 / 40,
      window = 8,
      line = 8,
      eps = 1
    ),
    .options = furrr::furrr_options(seed = seed))
)

# simulate two - estimated 0.14134
mean(
  furrr::future_map_lgl(1:B, function(x)
    sim_process(
      geq = 3,
      rate = 1 / 40,
      window = 8,
      line = 3560,
      eps = 1
    ),
    .options = furrr::furrr_options(seed = seed))
)

# simulate two - estimated 0.14134
mean(
  furrr::future_map_lgl(1:B, function(x)
    sim_process(
      geq = 3,
      rate = 1 / 40,
      window = 8,
      line = 3560,
      eps = 0.01
    ),
    .options = furrr::furrr_options(seed = seed))
)
