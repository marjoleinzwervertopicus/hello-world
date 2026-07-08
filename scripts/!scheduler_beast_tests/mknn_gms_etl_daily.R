#For running locally. Needed for use with old Library/database/database.R
Sys.setenv("DEVISE_DB_USER" = "postgres")
Sys.setenv("DEVISE_DB_USER_MYSQL" = "devise")

source("Library/init.R")
prepare <- import("Library/clients/mknn/dispatch_logistics/prepare_script.R")

prepare(c(ymd("2020-01-01"), ymd("2020-12-31")))
prepare(c(ymd("2021-01-01"), ymd("2021-12-31")))
prepare(c(ymd("2022-01-01"), Sys.Date()))