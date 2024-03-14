source("Library/init.R")
database <- import("Library/database/database.R")
connections <- database$get_connections("mmt_umcg")
#DATA in dashboard
connections$customer$get("SELECT MAX(receive_task_day) FROM task_logistic")




#inbox connection, config/postgres.user.name devise
connections <- database$get_connections("etl.mmt_umcg")
connections$customer$get("SELECT * FROM task_logistic_inbox LIMIT 10")
connections$customer$get("SELECT * FROM personnel_inbox LIMIT 10")
