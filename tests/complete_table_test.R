source("Library/init.R")
data_utilities <- import("Library/utilities/data.R")
database <- import("Library/database/database.R")
connections <- database$get_connections("rav_drenthe")
dataset <- connections$customer$get("SELECT * FROM ambulance_task_edaz LIMIT 1")

dataset$receive_task_weekend  <- as.character(dataset$iscompleted)
# dataset$destination_zipcode <- jsonlite::toJSON("test")
dataset$leeftijd <- 55.54
data_utilities$complete_table(dataset, connection = connections$customer, table_name = "ambulance_task_edaz")
