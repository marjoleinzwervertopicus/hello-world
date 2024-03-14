source("Library/init.R")
data_sources <- import("Library/calculate/data_sources.R")

data <- data_sources$connect("db rav_drenthe ambulance_task_edaz")

a1_performance_user_filters <- list(a1_performance = TRUE, or = list(first_call_centralist_user_email = user, deployment_centralist_user_email = user))

unapproved_filters <- list(needs_approval = TRUE, or = list(
  and = list(call_part_1_duration_delayed = TRUE, first_call_centralist_user_email = "user"), 
  and = list(call_part_2_duration_delayed = TRUE, deployment_centralist_user_email = "user")
))

data$count(filters = list(
  urgency = "A1",
  specialisme = list(values = "Huisarts"),
  
  urgency = list(operation = "IN", values = "A1")
))

data$count(filters = unapproved_filters)
