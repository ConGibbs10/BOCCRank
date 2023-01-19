# allow debugging
options(echo = TRUE)

print(getwd())
pkgs <- setdiff(sort(unique(renv::dependencies()$Package)), c('R', 'BOCCRank'))
install.packages(pkgs)
if ('BOCCRank' %in% installed.packages()[, 'Package']) {
  remove.packages('BOCCRank')
}
devtools::install()
