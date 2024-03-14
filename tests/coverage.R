# source("Library/init.R")
# db <- import("Library/database/db.R")
# 
# 
# date_filter <- c("2022-03-01", "2023-03-31")
# 
# resources <- resources_load("clients/rav_limburg_noord/sb_optimization/regio 23.csv")
# 
# stations <- resources %>% 
#   filter(type %in% c("Standplaats", "Station", "station", "VWS")) %>%
#   select(name, location, latitude, longitude)
# 
# resources2 <- resources_load("clients/rav_limburg_zuid/sb_optimization/regio 24.csv")
# 
# stations <- resources %>% 
#   filter(type %in% c("Standplaats", "Station", "station", "VWS")) %>%
#   select(name, location, latitude, longitude)
# 
# stations2 <- resources2 %>% 
#   filter(type %in% c("Standplaats", "Station", "station", "VWS")) %>%
#   select(name, location, latitude, longitude)
# 
# tasks_renco <- tasks_get(calculate_db = db("rav_limburg_noord ambulance_task_edaz", 
#                                            single_table_name = FALSE),
#                          date_filter = date_filter,
#                          filters = list(exclude = F, a1_performance = TRUE)) |>
#   mutate(task_id = paste0("23_", year(receive_task_datetime), "_", task_id))
# 
# tasks_renco2 <- tasks_get(calculate_db = db("rav_limburg_zuid ambulance_task_edaz", 
#                                             single_table_name = FALSE),
#                           date_filter = date_filter,
#                           filters = list(exclude = F, a1_performance = TRUE)) |>
#   mutate(task_id = paste0("24_", year(receive_task_datetime), "_", task_id))
# 
# coverage_tasks_renco2 <- tasks_add_coverage(
#   tasks_renco2,
#   stations2$location,
#   drive_time_limit = 12 * 60 * 1.2,
#   coverage_tasks_table = "coverage_tasks_limburg")
# 
# 
# coverage_tasks_renco <- tasks_add_coverage(
#   tasks_renco,
#   stations$location,
#   drive_time_limit = 12 * 60 * 1.2,
#   coverage_tasks_table = "coverage_tasks_limburg")
# 
# coverage_tasks_renco %>%
#   calculate_coverage_stats_renco(as_text = T)
# 
# 
# coverage_tasks_renco2 %>%
#   calculate_coverage_stats_renco(as_text = T)

# limburg_zuid_resources_path <- "clients/rav_limburg_zuid/sb_optimization/regio 24.csv"
limburg_noord_resources_path <- "clients/rav_limburg_noord/sb_optimization/regio 23.csv"
# brabant_resources_path <- "clients/rav_brabant_zuidoost/resources/resources_20230427.csv"

# limburg_zuid_string <- "rav_limburg_zuid ambulance_task_edaz"
limburg_noord_string <- "rav_limburg_noord ambulance_task_edaz"
# brabant_string <- "db shared rav_brabant_zuidoost_ambulance_task_new"

# render("modules/sb_optimalization/app_coverage.qmd", 
#        output_format = "html",
#        output_dir = "clients/rav_brabant_zuidoost/sb_optimization/2023_q1/",
#        params = list(
#          db_connection_string =  "db shared rav_brabant_zuidoost_ambulance_task_new",
#          resources_file = "clients/rav_brabant_zuidoost/resources/resources_20230427.csv",
#          date_filter = c("2021-01-01", "2023-03-31"))
# )
# 
# params <- list(
#   db_connection_string = limburg_noord_string,
#   resources_file = limburg_noord_resources_path,
#   date_filter =  c("2022-03-01", "2023-03-31"))
# 
# 
# library(tidyverse)
# library(leaflet)
# library(highcharter)
# 
# #import <<- function(file) source(file, local = T)$value
# import <- source("Library/import.R")$value(compiled = T, echo = T)
# 
# calculate_coverage_stats <- import("Library/calculate/scenario/calculate_coverage_stats.R")
# calculate_coverage_stats_renco <- import("Library/calculate/scenario/calculate_coverage_statistics.R")
# 
# match_coverage_tasks <- import("Library/calculate/scenario/match_coverage_tasks.R")
# tables <- import("Library/visualize/table/table.R")$create()
# maps <- import("Library/visualize/maps/maps.R")
# color_pal <- import("Library/visualize/color_pal.R")()
# tasks_add_coverage <- import("Library/calculate/scenario/tasks_add_coverage.R")
# tasks_get <- import("Library/calculate/scenario/tasks_get.R")
# 
# db <- import("Library/database/db.R")
# resources_load <- import("Library/calculate/scenario/resources_load.R")
# 
# data <- db(params$db_connection_string, single_table_name = F)
# resources <- resources_load(params$resources_file)
# 
# stations <- resources %>% 
#   filter(type %in% c("Standplaats", "Station", "station", "VWS")) %>%
#   select(name, location, latitude, longitude)
# 
# rav_num <- if(grepl(pattern = "rav_limburg_zuid", params$db_connection_string)) "24" else "23"
# 
# tasks_renco <- tasks_get(calculate_db = db(params$db_connection_string, 
#                                            single_table_name = FALSE),
#                          date_filter = c("2022-03-01", "2023-03-31"),
#                          filters = list(exclude = F, urgency = "A1", incident_rav_region = "RAV Noord- en Midden Limburg (23)")) |>
#   mutate(task_id = paste0(rav_num, "_", year(receive_task_datetime), "_", task_id))
# 
# connection <- db("geography")$connection
# 
# locations <- stations$location#[stations$name %in% input$locations]
# coverage_tasks_renco <- tasks_add_coverage(
#   tasks_renco,
#   locations,
#   drive_time_limit = 12 * 60 * 1.2,
#   coverage_tasks_table = "coverage_tasks_limburg",
#   connection = connection)
# 
# coverage_stats <- coverage_tasks_renco %>% calculate_coverage_stats_renco(as_text = T, drive_time_limit = 12, reach = c(11, 12))
# coverage_stats <- coverage_tasks_renco %>% calculate_coverage_stats(reach_range = c(11, 12))

library(tidyverse)
library(leaflet)
library(highcharter)

#import <<- function(file) source(file, local = T)$value
import <- source("Library/import.R")$value(compiled = T, echo = T)

calculate_coverage_stats <- import("Library/calculate/scenario/calculate_coverage_stats.R")
match_coverage_tasks <- import("Library/calculate/scenario/match_coverage_tasks.R")

db <- import("Library/database/db.R")
resources_load <- import("Library/calculate/scenario/resources_load.R")

params <- list(
  db_connection_string = limburg_noord_string,
  resources_file = limburg_noord_resources_path,
  date_filter =  c("2022-03-01", "2023-02-01"),
           task_filter = list(exclude = FALSE,
                            task_type_name = list(
                              values = c("Annulering",
                                         "Afgebroken",
                                         "Stand-by",
                                         "VWS",
                                         "Onderhoud/keuring",
                                         "Clustertraining"),
                              operation = "not in"),
                            vehicle_type = c("Ambulance"),
                            cat_a1_performance = TRUE)
  )

data <- db(params$db_connection_string, single_table_name = F)
resources <- resources_load(params$resources_file)

stations <- resources %>% 
  filter(type %in% c("Standplaats", "Station", "station", "VWS")) %>%
  select(name, location, latitude, longitude)

# run <- function(date_filter)
#run again
tasks <- data$select(
  calculate_column = 
    c("task_id",
      "receive_task_datetime", 
      "incident_latitude", 
      "incident_longitude", 
      "station_name"),
  date_filter = params$date_filter, 
  filters = params$task_filter)

coverage_tasks <- match_coverage_tasks(resources, tasks)

coverage_stats <- coverage_tasks %>%
  calculate_coverage_stats(location_names = stations$name, 
                           reach_range = c(11, 12) * 60 * 1.2)

coverage_stats$stats_text
