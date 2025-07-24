source("Library/init.R") 
database <- import("Library/database/database.R")
connections <- database$get_connections("rav_limburg_zuid")

#uitruktijden
id <- connections$customer$get(paste0("INSERT INTO ambulance_task_edaz (a1_performance, driver_email, preparation_duration, receive_task_datetime, exclude, task_id, receive_task_year) VALUES (TRUE, 'marjolein@devise.nl', 200, '",
                                      format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "', FALSE, 222223, 2024) RETURNING ambulance_task_edaz_id"))
connections$customer$get(paste0("SELECT driver_email FROM ambulance_task_edaz WHERE ambulance_task_edaz_id = ", id))



id <- connections$customer$get(paste0("INSERT INTO ambulance_task_edaz (a1_performance, driver_email, move_to_incident_duration, receive_task_datetime, exclude, task_id, receive_task_year) VALUES (TRUE, 'marjolein@devise.nl', 2000, '",
                                      format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "', FALSE, 222223, 2024) RETURNING ambulance_task_edaz_id"))
