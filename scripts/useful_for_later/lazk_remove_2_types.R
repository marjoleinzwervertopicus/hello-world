source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
dev_connection <- db_connect("lazk", preset = "postgres_development_server")

#219
dev_connection$query("SELECT id_provider_type FROM provider_type WHERE name = 'Verloskunde'")
#215
dev_connection$query("SELECT id_provider_type FROM provider_type WHERE name = 'Gemeentelijke gezondheidsdienst'")

#check
dev_connection$query("SELECT * FROM provider WHERE id_provider_type IN (219, 215)")

#delete
dev_connection$query("DELETE FROM provider WHERE id_provider_type IN (219, 215)")


