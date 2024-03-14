source("Library/init.R")
library(stringr)
files <- import("Library/utilities/files.R")

result_folder <- "~/RStudio/hello_world/!simulatie/matrix_resultaten_fryslan/"
# result_folder <- "~/RStudio/hello_world/!simulatie/matrix_resultaten_brabant/"

scenario_0_result <- files$load_file("~/RStudio/hello_world/!simulatie/scenario_1_default_geen_elektrisch_results.csv")

scenario_1_result <- files$load_file("~/RStudio/hello_world/!simulatie/scenario_3_cap_60_snel_50_results.csv")
scenario_2_result <- files$load_file("~/RStudio/hello_world/!simulatie/scenario_2_cap_60_snel_50_results.csv")




result_file_names <- list.files(result_folder)
result_file_names <- result_file_names[grepl("_cap_.*_snel_.*_results.csv", result_file_names)]

matrix_results <- tibble(
  capacity = character(0),
  speed = character(0),
  scenario_path = character(0),
  utilization = character(0),
  waiting_time = character(0),
  no_ambulance = character(0),
  drive_times = character(0),
  output_avg_drive_times = character(0),
  a1_performance = character(0),
  costs = character(0),
  a1_delays = character(0),
  a1_tasks = character(0),
  a2_tasks = character(0),
  b_tasks = character(0),
  total_tasks = character(0),
  performance_tasks = character(0),
  tasks_delayed = character(0),
  tasks_edge = character(0),
  scenario_name = character(0)
)

for(file_name in result_file_names) {
  results <- files$load_file(paste0(result_folder, file_name))
  
  capacity <- str_match(results$scenario_name, "cap_(.*?)_")[2]
  speed <-  str_match(results$scenario_name, "_snel_(.*)$")[2]
  
  results$capacity <- capacity
  results$speed <- speed
  
  matrix_results <- bind_rows(matrix_results, results)
}



matrix_results$a1_performance <- (as.numeric(matrix_results$a1_performance) - as.numeric(scenario_0_result$a1_performance)) * 100

matrix_results
scenario_0_result

