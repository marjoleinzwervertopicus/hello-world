packageVersion("duckdb")            # should now be the image's version, 1.5.5
duckdb::duckdb_storage_status()

source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")

# Same as el_intus_raw.R, without duckdb::duckdb_extension_storage("shared")
db_quack <- db_connect(preset = "duckdb")
db_quack$query("INSTALL json", get = F)
db_quack$query("LOAD json", get = F)

# Read one existing INTUS file (read-only), like the script does
file <- "/home/shared/data/intus/vrgz/ref_shift.json"
dataset <- db_quack$query("SELECT * FROM read_json({file})",
                          params = list(file = file), lazy = TRUE, echo = FALSE)
dplyr::glimpse(dplyr::collect(head(dataset, 5)))

db_quack$disconnect()
duckdb::duckdb_storage_status()
