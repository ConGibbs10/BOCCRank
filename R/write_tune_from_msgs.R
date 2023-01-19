#' Write tune results from msgs folder.
#'
#' @details Some tune results return a segmentation fault error. When the results,
#' are printed to msgs, save output by reading msgs. Otherwise, keep original TSV
#' file.
#'
#' @param array_path Folder containing the TSV files.
#' @param msgs_path Folder containing the msgs files.
#'
#' @return Nonempty TSV files.
#' @export
write_tune_from_msgs <- function(array_path, msgs_path) {
  if(!dir.exists(array_path)) {
    stop('Array directory does not exist.')
  }
  if(!dir.exists(msgs_path)) {
    stop('Messages directory does not exist.')
  }
  # get files with segmentation error
  tune_results <- list.files(array_path, full.names = T)
  msgs_results <-
    list.files(msgs_path, full.names = T, pattern = '*.out')
  faulty_tune_results <-
    tune_results[file.info(tune_results)$size - 0 <= sqrt(.Machine$double.eps)]
  # if there are faulty files, fix them
  counter <- 0
  if (length(faulty_tune_results) > 0) {
    for (f in faulty_tune_results) {
      index <-
        as.integer(stringr::str_remove(stringr::str_extract(f, '\\d+.tsv'), '.tsv'))
      msgs_indices <-
        as.integer(stringr::str_remove(stringr::str_extract(msgs_results, '\\d+.out'), '.out'))
      f_msgs <- msgs_results[msgs_indices %in% index]
      if (length(f_msgs) != 1) {
        counter <- counter + 1
        next
      }
      # isolate lines of interest
      lines <- readLines(f_msgs)
      lines <-
        tail(lines[-seq(length(lines) - 5, length(lines), 1)], 3)
      # save parameters
      ftsv <- tune_grid[index, ]
      # fix file
      if (any(stringr::str_detect(lines, 'Stopping'))) {
        dt <- lines[[2]]
        dt <- stringr::str_split(dt, '\\t|\\+')[[1]]
        dt <-
          as.numeric(stringr::str_remove_all(dt, '\\[|\\]|train-rmse:|test-rmse:'))

        ftsv$iter <- dt[1] + 50
        ftsv$train_rmse_mean <- dt[2]
        ftsv$train_rmse_std <- dt[3]
        ftsv$test_rmse_mean <- dt[4]
        ftsv$test_rmse_std <- dt[5]
        ftsv$best_iter <- dt[1]

        readr::write_tsv(ftsv, f)
      } else {
        dt <- lines[[3]]
        dt <- stringr::str_split(dt, '\\t|\\+')[[1]]
        dt <-
          as.numeric(stringr::str_remove_all(dt, '\\[|\\]|train-rmse:|test-rmse:'))
        if (ftsv$nrounds == dt[1]) {
          ftsv$iter <- dt[1]
          ftsv$train_rmse_mean <- dt[2]
          ftsv$train_rmse_std <- dt[3]
          ftsv$test_rmse_mean <- dt[4]
          ftsv$test_rmse_std <- dt[5]
          ftsv$best_iter <- dt[1]

          readr::write_tsv(ftsv, f)
        } else {
          counter <- counter + 1
        } # end error check
      } # end fix if there is no stopping rule
    } # end for loop
    if(counter > 0) {
      message('Some files could not be fixed.')
    }
  } # end if statement
}
