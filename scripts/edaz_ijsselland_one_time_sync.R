source("Library/init.R")

etl <- source("Library/modules/ambulance_logistics_edaz/etl.R")$value
prepare <- import("Library/modules/ambulance_logistics_edaz/prepare_script.R")


etl$process_inbox("rav_ijsselland", "task", "all")
prepare("rav_ijsselland", c(ymd("2011-01-01"), Sys.Date()))
