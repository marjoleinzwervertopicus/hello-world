source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")

db_app <- db_connect("rav_brabant_midden_west_noord", preset = "postgres_application_admin")
db_app_new <- db_connect("rav_brabant_midden_west_noord", preset = "postgres_application_new_admin")

table_names <- c(
  "account_names",
  "contracts",
  "function_requirements",
  "hours",
  "hours_planning",
  "raw_dim_us_activity_type",
  "raw_dim_us_date",
  "raw_dim_us_department",
  "raw_dim_us_employee",
  "raw_fact_us_assigned_activity",
  "raw_youforce",
  "resource",
  "resources",
  "sb_ambulance_task",
  "scenario"
)

for(table_name in table_names) {
  message("Copy table ", table_name, " from application to application_new")
  db_app$table(table_name) |> 
    db_app_new$write(table_name, overwrite = TRUE, copy_structure = TRUE)
}

db_app$disconnect()
db_app_new$disconnect()
