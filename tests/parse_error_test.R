# actual reproduction for error
# source("Library/init.R")
# prepare <- import("Library/clients/mk_limburg/dispatch_logistics/prepare_script.R")
# prepare(c(ymd("2019-01-01"), ymd("2019-12-31")), dry_run = T)


# mk limburg minimal reproduction that gives error
test_vector <- as.POSIXlt(c("2019-11-06 00:00:00", "2019-01-04 11:19:18", NA))

# other test vectors
test_vector <- (c("2019-11-06 00:00:01", "2019-01-04 11:19:18", NA, "2012/04/12 23:21:14"))
test_vector <- c("1/1/2026 2:46:38 AM",   "1/1/2026 10:06:37 AM",  "12/31/2025 7:05:50 PM", NA)



test_vector <- c(as.Date("2019-11-06 00:00:11"), "2019-01-15", NA, as.POSIXct("2012-04-13 23:21:14"))
test_vector2 <- c(as.POSIXt("2012-04-13 23:21:14"), as.Date("2019-11-06 00:00:11"), "2019-01-15 00:00:11", NA)
test_vector <- list(as.Date("2019-11-06 00:00:11"), NA, as.POSIXct("2012-04-13 23:21:14"))

test_vector <- c("1/1/2026 2:46:38 AM",   "1/1/2026 10:06:37 AM",  "12/31/2025 7:05:50 PM", NA, "2019-11-06 00:00:01")

parse <- source("Library/preparation/parse.R")$value
parse$vector$datetime(test_vector2)

is.POSIXt(test_vector2)

