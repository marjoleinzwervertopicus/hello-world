#Does not work for all tables because of dependencies between tables. Has not been used
source("Library/init.R")
Sys.setenv("DEVISE_DB_USER" = "postgres")

db_connect <- import("Library/database/db_connect.R")
dev_connection <- db_connect("lazk", preset = "postgres_development_server")
prod_connection <- db_connect("lazk", preset = "postgres_application_server")


tables_to_sync <- c("ambulance", "hospital", "municipality", "provider", "provider_type",
                    "province", "rav", "region", "roaz", "safety_region", "specialization", "specialization_type")

for(table_name in tables_to_sync) {
  prod_connection$table(table_name) |> dev_connection$write(table_name, overwrite = TRUE)
}

dev_connection$query("UPDATE roaz SET name = 'Netwerk Acute Zorg Noord-Holland/Flevoland' WHERE id_roaz = '408'")
dev_connection$query("SELECT * FROM roaz WHERE id_roaz = '407'")
