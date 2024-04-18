library(tidyr)
source("Library_old/prepare/load_local.R", local = TRUE)
data <- source("R/data/data.R", local = TRUE)$value()
customer_name <- data$download$customer()$name
customer_id <- data$download$customer()$customer_id

data_task_logistics <- load_files_from_dir(paste0("uploads/data/", customer_id, "/mmt_logistics/task_logistics")) |>
  map(function(x) { names(x) <- tolower(names(x)); x }) |>
  map(function(x) { 
    x$selected <- as.numeric(case_when(
      x$selected == "False" ~ "0",
      x$selected == "True" ~ "1",
      TRUE ~ as.character(x$selected)))
    x
  })
data_task_logistics[[1]] <- data_task_logistics[[1]] |> filter(!toupper(ritid) %in% toupper(data_task_logistics[[2]]$ritid))
data_task_logistics <- data_task_logistics |>
  bind_rows() |>
  mutate(ritid = toupper(ritid)) |>
  dplyr::select(-task_logistic_inbox_id) |>
  dplyr::select(-ts)


data <- data_task_logistics


data <- data[!duplicated(data[c("ritid", "item")], fromLast = TRUE), ]
data <- data %>% mutate(item = if_else(category %in% "Login" & item %in% "Chauffeur", "VPK", item)) |>
  #filter(selected %in% "1") %>% 
  dplyr::select(-category, -section, -selected) |>
  spread(key = item, value = value) 


data$month_day<- paste0(substr(data$Datum, 1, 7), "-01")
  
  
data %>% group_by(month_day) |> summarize(n = n())

#52
sum(grepl("2019-05", data$Datum))

sum(grepl("2019-01", data$Datum))#140
