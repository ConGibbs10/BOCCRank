#' Write ragged TSV file.
#'
#' @details A ragged TSV file is one with unequal number of columns per row.
#'
#' @param x A list to write to disk.
#' @param file File or connection to write to.
#'
#' @return A TSV file.
#' @export
write_ragged_tsv <- function(x, file) {
  xi <- purrr::map2(x, seq_along(x), function(el, i) c(i-1, el))
  xit <- purrr::map_chr(xi, function(el) paste0(el, collapse = '\t'))
  xitn <- paste0(xit, collapse = '\n')
  # check if extension exists
  pe <- fs::path_ext(file)
  if(nchar(pe) == 0) {
    file <- paste0(file, '.txt')
  }
  # write result
  writeLines(xitn, con = file)
}
