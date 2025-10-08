
source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
connections <- db_connect("rav_drenthe", preset = "postgres_development_server")
dataset_prepared <- connections$query("ALTER TABLE ambulance_task_edaz ADD COLUMN test1 boolean DEFAULT false")
connections$disconnect()

# dataset_prepared2 <- dataset_prepared |> select(-ambulance_task_edaz_id)
# #current prep
# connections <- source("Library/database/database.R", local = T)$value$get_connections(c("rav_drenthe", "geography"), persistent = TRUE)
# data_utilities <- import("Library/utilities/data.R")
# 
# connections$customer$in_transaction({
#   # data_utilities$create_or_complete_table(dataset_prepared, connections$customer, "ambulance_task_edaz")
#   # connections$customer$set("delete from ambulance_task_edaz WHERE edaz_id is null")
#   connections$customer$insert_table_unsafe("ambulance_task_edaz", dataset_prepared2)
# })
# data_utilities$create_indexes(connections$customer, "ambulance_task_edaz")
# connections$disconnect()


# source("Library/init.R")
# db_connect <- import("Library/database/db_connect.R")
# connections <- db_connect("rav_drenthe", preset = "postgres_development_server")
# active_queries <- connections$query("SELECT datname, state, query FROM pg_stat_activity WHERE state = 'active' AND query ILIKE '%ambulance_task_edaz%'")
# connections$disconnect()



set_postgres_grants(host = "postgres_development_server",
                    databases = "rav_drenthe",
                    users = c("niels@devise.nl", 
                              "marieke@devise.nl",
                              "bob.walraad@topicus.nl"),
                    read = TRUE,
                    write = FALSE)


