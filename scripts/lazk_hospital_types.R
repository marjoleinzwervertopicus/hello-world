source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
dev_connection <- db_connect("lazk", preset = "postgres_development_server")
dev_connection$query("SELECT * FROM specialization") |> View()
