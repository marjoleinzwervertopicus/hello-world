source("Library/init.R")
database <- import("Library/database/database.R")

connections <- database$get_connections("mmt_umcg")

initialize_details <- source("R/modules/mmt_logistics/initialize_details.R", local = TRUE)$value

details$patient_data


a <- details$patient_data %>% group_by(receive_task_month_day) %>% summarize(n = n())

#0
sum(details$patient_data %>% duplicated())

#0
sum(details$patient_data$task_logistic_id %>% duplicated())

#21125
sum(details$patient_data$mizis_id %>% duplicated())