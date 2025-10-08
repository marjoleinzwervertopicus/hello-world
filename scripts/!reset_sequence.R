source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
Sys.setenv("DEVISE_DB_USER" = "postgres")


client_name <- "mknn"
table_name <- "v_a_arc_inzet_eenheid"

connections <- db_connect(client_name, preset = "postgres_etl_server")
# connections$query("CREATE TABLE v_a_arc_inzet_kar_copy AS TABLE v_a_arc_inzet_kar")

# connections$query(paste0("SELECT nextval('", table_name, "_",  table_name, "_id_seq')"))
connections$query(paste0("ALTER SEQUENCE ", table_name, "_", table_name, "_id_seq RESTART WITH 1"))
connections$query(paste0("UPDATE ", table_name, " SET ", table_name, "_id=nextval('", table_name, "_",  table_name, "_id_seq')"))

connections$disconnect()
