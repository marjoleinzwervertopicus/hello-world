source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
Sys.setenv("DEVISE_DB_USER" = "postgres")

connections <- db_connect("rav_drenthe", preset = "postgres_etl_server")
connections$query("CREATE ROLE \"ruben.schenkhuizen@topicus.nl\" WITH LOGIN PASSWORD 'wachtwoord'")


connections$query("SELECT * FROM pg_roles")
connections$disconnect()
