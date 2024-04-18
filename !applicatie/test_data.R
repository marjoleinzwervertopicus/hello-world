source("Library/init.R")
test <- import("Library/utilities/test.R")

client <- "rav_drenthe"
client <- "rav_fryslan"

client <- "rav_limburg_noord"
client <- "rav_limburg_zuid"
client <- "mk_limburg"
client <- "rav_ijsselland"
client <- "mk_limburg"
client <- "mknn"

test <- test$create(client_code = client)


test$has_new_data("ambulance_task_edaz")
test$diff_preparation("ambulance_task_edaz")



test$has_new_data("edaz_form_inbox")
test$diff_data("ambulance_task_edaz")


test$diff_preparation("gms_task")

test$diff_preparation("ambulance_task_edaz", c(ymd("2011-01-01"), Sys.Date()))


#limburg zuid, removed columns
test$diff_preparation("ambulance_task_edaz")

#no diff?
test$diff_preparation("ambulance_task_edaz", c(ymd("2011-01-01"), Sys.Date()))







