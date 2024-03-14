source("Library/rmd/init_dashboard.R") 

data <- data_sources$connect("db mknn dispatch_task_gms")

daterange_select <- list(values = c('2023-01-01', '2023-03-31'))

filter_rav <- 
  list(provider_name = data$count(groups = "provider_name")$provider_name) 

system.time({
result <- 
  data$average(calculate_column = "call_part_1_duration",
               date_filter = daterange_select$values,
               time_column = "receive_task",
               filters = c(
                 list(urgency_dispatcher = "A1"), 
                 filter_rav),
               exclude_excluded = TRUE)$y


result2 <- data$average(calculate_column = "call_part_1_duration",
               date_filter = c(Sys.Date() %m-% months(3), Sys.Date()),
               time_column = "receive_task",
               time = "weekly",
               filters = c(
                 list(urgency_dispatcher = "A1"), 
                 filter_rav),
               exclude_excluded = TRUE)
})


system.time({
  date_filter <- c(min(as.Date(daterange_select$values[1]), Sys.Date() %m-% months(3)), max(as.Date(daterange_select$values[2]), Sys.Date()))
  a <- data$select(#calculate_column = "call_part_1_duration",
              date_filter = date_filter,
              time_column = "receive_task",
              filters = c(
                list(urgency_dispatcher = "A1"), 
                filter_rav),
              exclude_excluded = TRUE)
  
  
  temp <- a[a$receive_task_datetime > daterange_select$values[1] & a$receive_task_datetime < paste0(daterange_select$values[2], " 23:59:59"), ]
  result_1_1 <- mean(temp$call_part_1_duration, na.rm = T)
  
  
  temp <- a[a$receive_task_datetime > Sys.Date()  %m-% months(3) & a$receive_task_datetime < paste0(Sys.Date(), " 23:59:59"), ]
  result2_2 <- temp %>% group_by(receive_task_week_day) %>% summarize(n = n(), y = mean(call_part_1_duration, na.rm = T)) %>% rename(x = receive_task_week_day)
  result2_2 <- result2_2 %>% mutate(across(n, as.double))
})


