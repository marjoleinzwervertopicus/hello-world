# https://style.tidyverse.org/syntax.html#long-lines

# I do not like
dataset <- geography$geocode_batch("dataset", search_prefix = "incident_", match_by = "zipcode", prefix = "incident_", return = c("municipality", "province", "place"), bind = T, hex_grid = T)


# I like
dataset <- geography$geocode_batch(
  dataset,
  search_prefix = "incident_",
  match_by = "zipcode",
  prefix = "incident_",
  return = c("municipality", "province", "place"),
  bind = TRUE,
  hex_grid = TRUE
)


# Good
do_something_very_complicated(
  something = "that",
  requires = many,
  arguments = "some of which may be long"
)

# Bad
do_something_very_complicated(
  "that", requires, many, arguments,
  "some of which may be long"
)




list(
  a = function() {

    test <- 1

  },

  b = function() {

  },
  d = function() {

  }
)
