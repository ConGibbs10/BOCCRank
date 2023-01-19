#' Rescale vector of values.
#'
#' @param x Vector of positive values.
#' @param smin Minimum value after scaling.
#' @param smax Maximum value after scaling.
#'
#' @return A vector.
#' @export
rescale <- function(x, smin = 0, smax = 1) {
  # check input
  if(smax <= smin) {
    stop('smax must be larger than smin.')
  }

  # rescale between 0 and 1
  y <- (x-min(x))/(max(x)-min(x))
  y[is.infinite(y)] <- 1
  y[is.nan(y)] <- 1
  y[is.na(y)] <- 1

  # rescale between requested values
  y <- (smax - smin)*y + smin

  return(y)
}
