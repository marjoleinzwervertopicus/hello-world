source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")

db_app <- db_connect("rav_fryslan", preset = "postgres_application_admin")
db_app_new <- db_connect("rav_fryslan", preset = "postgres_application_new_admin")

table_names <- c(
  "ambulance_track_webfleet",
  "edaz_log",
  "simulation",
  "scenario",
  "resource",
  "ambulance_task_edaz",
  "downtime",
  "edaz_task_raw",
  "edaz_form_raw",
  "flight",
  "hospital",
  "logistic",
  "qa",
  "shift",
  "station",
  "contract_raw",
  "contracted_time_raw",
  "deployments_specification_raw",
  "deployments_raw",
  "personnel_contract",
  "personnel_hours",
  "ritten_edazng_raw",
  "ritten_edazng"
)

for(table_name in table_names) {
  message("Copy table ", table_name, " from application to application_new")
  db_app$table(table_name) |> 
    db_app_new$write(table_name, overwrite = TRUE, copy_structure = TRUE)
}

db_app$disconnect()
db_app_new$disconnect()
