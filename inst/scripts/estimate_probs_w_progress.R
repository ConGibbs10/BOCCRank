# allow debugging
options(echo = TRUE)

# get number of cores
parallel::detectCores()

seed <- 6546
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
future::plan('multisession', workers = 46)
B <- 100000

# compute one
f <- function(k) (((8/40)^k)/factorial(k))*exp(-8/40)
1-f(0)-f(1)-f(2)

# simulate one to check
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


# simulate two
simulate_lower_bound <- function(eps) {
  p <- progressr::progressor(steps = B)

  furrr::future_map_lgl(1:B, function(x) {
    p()
    sim_process(
      geq = 3,
      rate = 1 / 40,
      window = 8,
      line = 3560,
      eps = eps
    )
  },
  .options = furrr::furrr_options(seed = seed))
}
progressr::with_progress({lb <- simulate_lower_bound(eps = 0.01)})
mean(lb)


# simulate three
x_eps <- exp(seq(log(0.01), log(8), length.out = 10))
y <- vector('numeric', length = length(x_eps))

for(i in 1:length(x_eps)) {
  cat(i, '\n')
  progressr::with_progress({lb <- simulate_lower_bound(eps = x_eps[i])})
  mean(lb)
}
