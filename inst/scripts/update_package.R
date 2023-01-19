# allow debugging
options(echo = TRUE)

print(getwd())
pkgs <- setdiff(sort(unique(renv::dependencies()$Package)), c('ECoHeN', 'R', 'LPCTA'))
install.packages(pkgs)
if ('LPCTA' %in% installed.packages()[, 'Package']) {
  remove.packages('LPCTA')
}
devtools::install()
