source("Library/init.R")

database <- import("Library/database/database.R")
drenthe_connection <- database$get_connections("rav_drenthe")$customer
mmt_gr_connection <- database$get_connections("mmt_gr")$customer


mmt_calc <- import("Library/modules/mmt_logistics/calculate_db.R")$create()
edaz_calc <- import("Library/modules/ambulance_logistics_edaz/calculate_db.R")$create()

result_drenthe <- edaz_calc$select(connection = drenthe_connection, calculate_column = "urgency")
result_mmt_gr <- mmt_calc$select(connection = mmt_gr_connection, calculate_column = "urgency")



a <- mmt_gr_connection$show_columns("capacity")
b <- mmt_gr_connection$show_columns("task_prepared")

intersect(a$column_name, b$column_name)

