# 4 arguments are accepted:
# - path: working directory
# - query_file: path to the query file
# - time: selects the corresponding time query - daily, monthly, all
# - drop: drop the table before inserting new data


args <- commandArgs(TRUE)
path <- args[1]
if(!is.na(path)) setwd(path)
query_file <- args[2]
if(is.na(query_file)) query_file <- "clients/rav_ijsselland/ambulance_logistics_edaz/edaz_task_inbox.sql"
time <- args[3]
if(is.na(time)) time <- "daily"
drop <- as.logical(args[4])
if(is.na(drop)) drop <- FALSE

secrets <- source("secrets.R")$value
connect <- source("connect_new.R")$value

input_connection <- connect$sql_server(
  driver = "SQL Server",
  host = "RAVEDAZ\\EDAZ",
  port = "1433",
  database = "ERF 2.0",
  user = "sa",
  password = secrets$get("sql_server", "sa", "C:/install/Devise R ETL")
)

query <- paste0(
  readLines("modules/ambulance_logistics_edaz/read_uncommitted.sql"),
  paste(readLines(paste0("modules/ambulance_logistics_edaz/", time, ".sql")), collapse = "\n"),
  paste(readLines(query_file), collapse = "\n")
)

dataset <- input_connection$query(query)

output_config <- list(
  dsn = "devise-etl-postgres",
  table_name = paste0("edaz_task_", time, "_inbox")
)

#test
# output_config$table_name <- "edaz_task_all_inbox"

output_connection <- connect$postgresql_dsn(dsn = output_config$dsn)

output_table_exists <- output_connection$query(paste0("SELECT COUNT(*) > 0 AS exists FROM information_schema.tables WHERE table_name = '", output_config$table_name, "'"))$exists

if(output_table_exists && drop) {
  output_connection$query(paste0("DROP TABLE ", output_config$table_name))
}

output_connection$insert_table(output_config$table_name, dataset)
# 
# output_ts_exists <- output_connection$query(paste0("SELECT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = '", output_config$table_name, "' AND column_name = 'ts');"))$exists
# if(!output_ts_exists) {
#   output_connection$query(paste0("ALTER TABLE ", output_config$table_name, " ADD COLUMN ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP"))
# }