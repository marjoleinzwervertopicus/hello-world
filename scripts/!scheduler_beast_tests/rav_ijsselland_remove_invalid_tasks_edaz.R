#For running locally. Needed for use with old Library/database/database.R
Sys.setenv("DEVISE_DB_USER" = "postgres")
Sys.setenv("DEVISE_DB_USER_MYSQL" = "devise")

source("Library/init.R")
etl <- import("Library/modules/ambulance_logistics_edaz/etl.R")

#This schedule is run before the sync at 2:45, since the valid tasks ETL query can take long, and might not be finished when running the daily script at 4:15
etl$remove_invalid_tasks("rav_ijsselland", "2021-01-01")



  


