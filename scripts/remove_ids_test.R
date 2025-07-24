prepare_helpers <- import("Library/modules/ambureports/functions/prepare_reports.R") # Load specific preparation for Ovdg
db_connect <- import("Library/database/db_connect.R") # Import database connection function


drenthe_dev_con <- db_connect(
  "rav_drenthe",
  preset = "postgres_development_server"
)

ambulance_task_edaz_ids <- drenthe_dev_con$query(paste0("SELECT edaz_id FROM ambulance_task_edaz LIMIT 2"))$edaz_id



removed_ids <- ambulance_task_edaz_ids

removed_ids_count <- drenthe_dev_con$query(paste0("SELECT COUNT(*) FROM ambulance_task_edaz WHERE edaz_id IN ('C6BC3796-B0C3-4300-B186-60C90202F154', 'E3FC18A7-E841-401E-B51B-35D3E0A17FC1')"))

ambulance_task_edaz_count <- drenthe_dev_con$query(paste0("SELECT COUNT(*) FROM ambulance_task_edaz"))

removed_ids <- NULL
prepare_helpers$remove_removed_trips(
  db_source = drenthe_dev_con,
  table_name = "ambulance_task_edaz",
  id_column = "edaz_id",
  removed_ids = removed_ids
)
