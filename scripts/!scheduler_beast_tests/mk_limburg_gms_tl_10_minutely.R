#For running locally. Needed for use with old Library/database/database.R
Sys.setenv("DEVISE_DB_USER" = "postgres")
Sys.setenv("DEVISE_DB_USER_MYSQL" = "devise")

source("Library/init.R")
prepare <- import("Library/clients/mk_limburg/dispatch_logistics/prepare_script.R")

dataset <- prepare(c(Sys.Date() %m-% days(1), Sys.Date()), dry_run = T)

#484
warning("prepared number of rows: ", nrow(dataset))

