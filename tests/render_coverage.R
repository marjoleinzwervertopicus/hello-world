source("Library/init.R")
render <- import("deploy/render.R")
open <- import("deploy/open.R")


limburg_zuid_resources_path <- "clients/rav_limburg_zuid/sb_optimization/regio 24.csv"
limburg_noord_resources_path <- "clients/rav_limburg_noord/sb_optimization/regio 23.csv"

limburg_zuid_string <- "rav_limburg_zuid ambulance_task_edaz"
limburg_noord_string <- "rav_limburg_noord ambulance_task_edaz"


file_path <- render("modules/sb_optimalization/app_coverage.qmd", 
       output_format = "html",
       output_dir = paste0("~/", "app_coverage"),
       params = list(
         db_connection_string =  limburg_zuid_string,
         resources_file = limburg_zuid_resources_path,
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
                            cat_a1_performance = TRUE),
         date_filter = c("2022-01-01", "2023-05-31"))
)

open(file_path)




#backup noord, 88.06 with NA

file_path <- render("modules/sb_optimalization/app_coverage.qmd",
                    output_format = "html",
                    output_dir = paste0("~/", "app_coverage"),
                    params = list(
                      db_connection_string =  limburg_noord_string,
                      resources_file = limburg_noord_resources_path)
)

open(file_path)


file_path <- render("clients/rav_limburg/analyse_standplaatsen_2023/app_coverage.qmd", 
                    output_format = "html",
                    output_dir = paste0("~/", "app_coverage"),
                    params = list(
                      db_connection_string =  limburg_noord_string,
                      resources_file = limburg_noord_resources_path,
                      coverage_tasks_table = "coverage_tasks_limburg_23",
                      date_filter = c("2022-01-01", "2023-05-31")
                    )
)

open(file_path)


