#For running locally. Needed for use with old Library/database/database.R
Sys.setenv("DEVISE_DB_USER" = "postgres")
Sys.setenv("DEVISE_DB_USER_MYSQL" = "devise")

source("Library/init.R")
etl <- import("Library/modules/ambulance_logistics_edaz/etl.R")
prepare <- import("Library/modules/ambulance_logistics_edaz/prepare_script.R")

etl$process_inbox("rav_ijsselland", "task", "monthly")
etl$process_inbox("rav_ijsselland", "form", "monthly")
prepare("rav_ijsselland", c(ymd("2011-01-01"), Sys.Date()))