source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
Sys.setenv("DEVISE_DB_USER" = "postgres")

connections <- db_connect("rav_drenthe", preset = "postgres_development_server")
roaz_shapes <- connections$query("CREATE ROLE \"nora.ali@topicus.nl\" WITH LOGIN PASSWORD 'abc")


connections$query("SELECT * FROM pg_roles")
connections$disconnect()
