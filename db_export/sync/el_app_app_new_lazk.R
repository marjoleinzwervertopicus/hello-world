source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")

db_app <- db_connect("lazk", preset = "postgres_application_admin")
db_app_new <- db_connect("lazk", preset = "postgres_application_new_admin")

table_names <- c(
  "ambulance",
  "client_info",
  "drive_time_ambulance_2020_night",
  "drive_time_ambulance_2020_rushhour",
  "drive_time_ambulance_2020_day",
  "drive_time_hap",
  "hospital",
  "municipality",
  "provider",
  "provider_type",
  "province",
  "rav",
  "region",
  "roaz",
  "safety_region",
  "specialization",
  "specialization_type",
  "drive_time_ambulance",
  "drive_time_person"
)

for(table_name in table_names) {
  message("Copy table ", table_name, " from application to application_new")
  db_app$table(table_name) |> 
    db_app_new$write(table_name, overwrite = TRUE, copy_structure = TRUE)
}

db_app$disconnect()
db_app_new$disconnect()
