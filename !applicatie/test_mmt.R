source("Library/init.R")
database <- import("Library/database/database.R")
files <- import("Library/utilities/files.R")
connections <- database$get_connections("mmt_umcg")

initialize_details <- source("R/modules/mmt_logistics/initialize_details.R", local = TRUE)$value

details <- list(patient_data = readRDS("patient_data.RDS"))


# a <- details$patient_data %>% group_by(receive_task_month_day) %>% summarize(n = n())
# 
# #0
# sum(details$patient_data %>% duplicated())
# 
# #0
# sum(details$patient_data$task_logistic_id %>% duplicated())
# 
#21685
sum(details$patient_data$task_id %>% duplicated())


#21125
sum(details$patient_data$mizis_id %>% duplicated())

#20.671 van de 33531
sum(details$patient_data %>% select(-task_logistic_id) %>% duplicated())


duplicated <- details$patient_data[details$patient_data %>% select(-task_logistic_id) %>% duplicated(), ]
duplicated_all <- details$patient_data[details$patient_data %>% select(-task_logistic_id) %>% duplicated() | details$patient_data %>% select(-task_logistic_id) %>% duplicated(fromLast=T), ]

#n = 4  8 12  1  3  2 16  6 20
#n = 5, 9, 13, 2, 4, 3, 17, 7, 21
a <- duplicated_all %>% group_by(task_id) %>% summarize(n = n())
a %>% select(n) %>% group_by(n) %>% summarize(n2 = n())

#25847
mizis_dup <- duplicated_all$mizis_id %>% duplicated() | duplicated_all$mizis_id %>% duplicated(fromLast = T)
sum(mizis_dup)

#25847
task_id_dup <- duplicated_all$task_id %>% duplicated() | duplicated_all$task_id %>% duplicated(fromLast = T)
sum(task_id_dup)


b <- which(duplicated$task_id %>% duplicated() & !duplicated$mizis_id %>% duplicated())

sum(duplicated  %>% select(-task_logistic_id) %>% duplicated())




#raw table test

#5
duplicated_all %>% filter(mizis_id == "000D375D-6660-4EBB-BA22-6B497F119CA5") %>% nrow()


connections$customer$show_columns("task_logistic")
c <- connections$customer$get("select * from task_logistic WHERE mizis_id = '000D375D-6660-4EBB-BA22-6B497F119CA5'")

task_logistics <- files$load_files("/srv/shiny-server/mmt_umcg/uploads/data/6/mmt_logistics/task_logistics/task_logistics.csv")
task_medical <- files$load_file("/srv/shiny-server/mmt_umcg/uploads/data/6/mmt_logistics/task_medical/task_medical.csv")

#0
task_medical %>% filter(ritid == "000D375D-6660-4EBB-BA22-6B497F119CA5") %>% nrow()


#25.847
duplicated_all <- data_patient[data_patient %>% select(-task_logistic_id) %>% duplicated() | data_patient %>% select(-task_logistic_id) %>% duplicated(fromLast=T), ]



duplicated_all <- data_patient[data_patient %>% select(-task_logistic_id) %>% duplicated() | data_patient %>% select(-task_logistic_id) %>% duplicated(fromLast=T), ]

data_patient_logistic
