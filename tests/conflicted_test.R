library(conflicted)
conflict_prefer_all("lubridate", "data.table")

conflicts_prefer(
  dplyr::slice
)
library(dplyr)
library(xgboost)

slice

conflicted::conflict_scout()
