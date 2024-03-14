connection <- dbConnect(RPostgres::Postgres(), host = "localhost", dbname = "rav_drenthe", user = "marjolein", password = secrets$get("postgres", "marjolein"), timezone = "CET", bigint = "numeric")
dbGetQuery(connection, "SELECT COUNT(*) FROM ambulance_task_edaz")


connection <- dbConnect(RPostgres::Postgres(), host = "localhost", dbname = "hap", user = "marjolein", password = secrets$get("postgres", "marjolein"), timezone = "CET", bigint = "numeric")
dbGetQuery(connection, "SELECT COUNT(*) FROM ambulance_task_edaz")

