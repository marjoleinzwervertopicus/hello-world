source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")

db_app <- db_connect("mmt_gr", preset = "postgres_application_admin")
db_app_new <- db_connect("mmt_gr", preset = "postgres_application_new_admin")

table_names <- c(
  "task_prepared",
  "capacity",
  "daylightperiod",
  "deletedritidsperuser_raw",
  "drfformdata_raw",
  "drfrit_raw",
  "drfusers_raw",
  "notcompletedritidsview_raw",
  "task_combined"
)

for(table_name in table_names) {
  message("Copy table ", table_name, " from application to application_new")
  db_app$table(table_name) |> 
    db_app_new$write(table_name, overwrite = TRUE, copy_structure = TRUE)
}

db_app$disconnect()
db_app_new$disconnect()
