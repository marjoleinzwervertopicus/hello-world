dataset <- geography$geocode_batch("dataset", search_prefix = "incident_", match_by = "zipcode", prefix = "incident_", return = c("municipality", "province", "place"), bind = T, hex_grid = T)

dataset <- geography$geocode_batch("dataset",
  search_prefix = "incident_",
  "zipcode",
  prefix = "incident_",
  return = c("municipality", "province", "place"),
  T,
  T
)


dataset <- geography$geocode_batch(
  data = "dataset",
  search_prefix = "incident_",
  match_by = "zipcode",
  prefix = "incident_",
  return = c("municipality", "province", "place"),
  bind = T,
  hex_grid = T
)


a <- 1

a <- T

1 + 1 <- 2

DayOne

a <- function() {
  line_1 <- 1
  # some newlines here



  line_1 <- 1
}


x[, 1]
x[, 1]
x[, 1]



mean(x, na.rm = TRUE)
mean(x, na.rm = TRUE)


if (debug) {
  show(x)
}

function(x) {}
function(x) {}


sqrt(x^2 + y^2)
df$ z
x <- 1:10


~foo
tribble(
  ~col1, ~col2,
  "a", "b"
)



# Good
list(
  total = a + b + c,
  mean  = (a + b + c) / n
)

# Also fine
list(
  total = a + b + c,
  mean = (a + b + c) / n
)

# Bad
if (y < 0 && debug) {
  message("Y is negative")
}

if (y == 0) {
  if (x > 0) {
    log(x)
  } else {
    message("x is negative or zero")
  }
} else {
  y^x
}


# Bad
if (y < 0) stop("Y is negative")

if (y < 0) {
  stop("Y is negative")
}

find_abs <- function(x) {
  if (x > 0) {
    return(x)
  }
  x * -1
}


find_abs <- function(x) {
  if (y < 0) {
    return("Y is negative")
  }
  x * -1
}


# Bad
if (length(x)) {
  # do something
}


do_something_very_complicated(
  "that", requires, many, arguments,
  "some of which may be long"
)



# Bad
'Te"xt'
'Text with "double" and \'single\' quotes'

this <- list(
  function(abc) {

  },
  function(abc) {

  },
)

function_call <- function(function_arg) {
  function_arg(1)
}


function_call(function_arg = function() {
  if (T) {
    1
  } else {
    2
  }
})


function_call("setwd", function(wd) {
  if (!grepl("/Platform$", wd)) {
    send_error(paste0("Function setwd was used with wd other than Platform. wd: "))
  } else {
    base::setwd(wd)
  }
},
envir = .GlobalEnv
)


# Before
if (x > 3) {
  stop("this is an error")
} else {
  c(
    there_are_fairly_long,
    1 / 33 *
      2 * long_long_variable_names
  ) %>% k()
}


# Before
my_fun <- function(
    x,
    y,
    z) {
  just(z)
}
