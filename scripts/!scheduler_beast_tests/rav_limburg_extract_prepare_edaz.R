source("Library/init.R")
edaz_prepare <- import("Library/modules/ambulance_logistics_edaz/prepare_functions.R")

# date_filter <- c(as.Date("2026-01-01"), Sys.Date() + lubridate::days(1))
# source("clients/rav_limburg/data/extract_edaz_23.R")$value(date_filter)
edaz_prepare$process_task_inbox("rav_limburg_zuid", inbox_location = "etl")
edaz_prepare$process_form_inbox("rav_limburg_zuid", inbox_location = "etl")
# 
# source("clients/rav_limburg/data/prepare_ambulance_task_23.R")$value(date_filter)
# source("clients/rav_limburg/data/prepare_ambulance_task_24.R")$value(date_filter)