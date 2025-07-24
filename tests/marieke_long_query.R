source("Library/init.R")


Sys.setenv("DEVISE_DB_USER" = "marieke@devise.nl")
Sys.setenv("DEVISE_DEFAULT_DB_HOST " = "postgres_application_server")


db_connect <- import("Library/database/db_connect.R")
prepare <- import("Library/modules/mmt_logistics/prepare.R")
db <- db_connect(dbname = "mmt_gr")
db_geography <- db_connect(dbname = "geography")
date_filter <- c(as.Date("2025-01-01"), Sys.Date() - lubridate::days(1))
task_combined <- db$query("SELECT * FROM task_combined WHERE \"RitDatum\" >= {date_filter_1} AND \"RitDatum\" <= {date_filter_2}",
                          params = list(date_filter_1 = date_filter[1],
                                        date_filter_2 = date_filter[2]))
drfusers_raw <- db$query("SELECT * FROM drfusers_raw")
place_info <- db_geography$query("SELECT * FROM place_info")
task_prepared <- prepare(task_combined, table_bag_woonplaats = place_info, table_users = drfusers_raw, use_exclude_label = T)