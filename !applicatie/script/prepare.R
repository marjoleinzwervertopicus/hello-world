source("Library/init.R")
# prepare_functions <- import("Library/modules/ambulance_logistics_edaz/prepare_functions.R")
prepare <- import("Library/modules/ambulance_logistics_edaz/prepare_script.R")
# files <- import("Library/utilities/files.R")
# 
# database <- import("Library/database/database.R")
# connections <- database$get_connections(c("rav_fryslan", "etl.rav_fryslan"))
# 
# 
# edaz_task_inbox <- files$load_file("task_08_06_23.csv")
# colnames(edaz_task_inbox) <- tolower(colnames(edaz_task_inbox))
# edaz_form_inbox <- files$load_file("form_08_06_23.csv")
# colnames(edaz_form_inbox) <- tolower(colnames(edaz_form_inbox))
# edaz_valid_task_inbox <- files$load_file("ritids_08_06_23.csv")
# colnames(edaz_valid_task_inbox) <- tolower(colnames(edaz_valid_task_inbox))
# 
# connections$etl.rav_fryslan$set("TRUNCATE TABLE edaz_task_inbox")
# connections$etl.rav_fryslan$set("TRUNCATE TABLE edaz_form_inbox")
# connections$etl.rav_fryslan$set("TRUNCATE TABLE edaz_valid_task_inbox")
# 
# connections$etl.rav_fryslan$insert_table_unsafe("edaz_task_inbox", edaz_task_inbox)
# connections$etl.rav_fryslan$insert_table_unsafe("edaz_form_inbox", edaz_form_inbox)
# connections$etl.rav_fryslan$insert_table_unsafe("edaz_valid_task_inbox", edaz_valid_task_inbox)
# 
# 
# prepare_functions$remove_invalid_tasks("rav_fryslan", inbox_location = "etl")
# prepare_functions$process_task_inbox("rav_fryslan", inbox_location = "etl")
# prepare_functions$process_form_inbox("rav_fryslan", inbox_location = "etl")

result <- prepare("rav_fryslan", date_filter = c("2020-01-01", "2024-01-01"), form = TRUE, dry_run = FALSE)
