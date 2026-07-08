source("Library/init.R")
edaz_prepare <- import("Library/modules/ambulance_logistics_edaz/prepare_functions.R")

source("clients/rav_limburg/data/extract_edaz_23.R")$value(c(Sys.Date() - days(1), Sys.Date() + days(1)))
edaz_prepare$process_task_inbox("rav_limburg_zuid", daily = TRUE, inbox_location = "etl")
edaz_prepare$process_form_inbox("rav_limburg_zuid", daily = TRUE, inbox_location = "etl")

source("clients/rav_limburg/data/prepare_ambulance_task_23.R")$value(c(Sys.Date() - days(1), Sys.Date() + days(1)))
source("clients/rav_limburg/data/prepare_ambulance_task_24.R")$value(c(Sys.Date() - days(1), Sys.Date() + days(1)))