# allow debugging
options(echo = TRUE)

print(getwd())
if ('BOCCRank' %in% installed.packages()[, 'Package']) {
  remove.packages('BOCCRank')
}
devtools::install()
