source("Library/rmd/init_dashboard.R") 

data <- data_sources$connect("db mknn dispatch_task_gms")
date_utilities <- import("Library/utilities/dates.R")
params <- list(provider_name = "Groningen")
daterange_select <- list(values = date_utilities$get_last_quarter())

filter_rav <- 
  list(provider_name = params$provider_name)

#running this code seems to make code below slower
result <-
  data$count(date_filter = daterange_select$values,
             filters = filter_rav,
             time_column = "receive_task",
             groups = "urgency",
             exclude_excluded = TRUE)


system.time({
  result <-
    data$average(calculate_column = "call_part_1_duration",
                 date_filter = daterange_select$values,
                 time_column = "receive_task",
                 filters = c(
                   list(urgency_dispatcher = "A1"),
                   filter_rav),
                 exclude_excluded = TRUE)$y
})
