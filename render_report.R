# source("Library/init_analysis.R")
assign("import", source("Library/import.R")$value())
reports <- source("Library/utilities/reports.R")$value
library(rlang)
source("deploy/init.R")
message <- function(...) cli::cli_inform(paste(...))
Sys.setenv("DEVISE_DB_USER" = "postgres")
# options(lifecycle_verbosity = "error")


render(
  file = "modules/scenario_editor/dashboard.Rmd",
  params = list(
    client = "rav_drenthe"
  )
) |> open()



# a <- render("~/RStudio/reports/clients/rav_drenthe/dashboards/medewerker_rmd/dashboard.qmd", output_format = "html") 
# 
# a |> open()

# options(warn=2)
source("Library/init_analysis.R")





reports$render("modules/ambulance_logistics_edaz/dashboards/logistics_insurer/dashboard.Rmd",
               params = list(client = "rav_drenthe",
                             database = "ambulance_task_edaz"),
               runtime = "shiny_prerendered",
               open = T)

reports$render("~/RStudio/reports/modules/sb_optimalization/app_coverage.qmd", open = T, output_format = "html")


reports$render("~/RStudio/Platform/insights/production_rmd/dashboard.Rmd", open = FALSE)
reports$render("~/RStudio/Platform/insights/data_quality_rmd/dashboard.Rmd", open = FALSE)


limburg_zuid_resources_path <- "clients/rav_limburg_zuid/sb_optimization/regio 24.csv"
limburg_noord_resources_path <- "clients/rav_limburg_noord/sb_optimization/regio 23.csv"
brabant_resources_path <- "clients/rav_brabant_zuidoost/resources/resources_20230427.csv"

limburg_zuid_string <- "rav_limburg_zuid ambulance_task_edaz"
limburg_noord_string <- "rav_limburg_noord ambulance_task_edaz"
brabant_string <- "db shared rav_brabant_zuidoost_ambulance_task_new"

# render("modules/sb_optimalization/app_coverage.qmd", 
#        output_format = "html",
#        output_dir = "clients/rav_brabant_zuidoost/sb_optimization/2023_q1/",
#        params = list(
#          db_connection_string =  "db shared rav_brabant_zuidoost_ambulance_task_new",
#          resources_file = "clients/rav_brabant_zuidoost/resources/resources_20230427.csv",
#          date_filter = c("2021-01-01", "2023-03-31"))
# )

params <- list(
  db_connection_string = limburg_zuid_string,
  resources_file = limburg_zuid_resources_path,
  date_filter =  c("2022-01-01", "2023-05-31"))


# resources <- resources_load(params$resources_file)
# 
# resources %>%
#   filter(type %in% c("Standplaats", "Station", "station", "VWS")) %>%
#   select(name, location, latitude, longitude)


quarto::quarto_render("modules/sb_optimalization/app_coverage.qmd", output_format = "html", execute_params = params)

quarto::quarto_render("clients/rav_limburg/analyse_standplaatsen_2023/app_coverage.qmd", output_format = "html", execute_params = list())

reports$render("~/RStudio/reports/modules/sb_optimalization/app_coverage.qmd")


reports$render("~/RStudio/Platform/insights/mka_management_empty/mka_management.Rmd", open = T)



reports$render("~/RStudio/Platform/insights/mka_management_profile/mka_management.Rmd", open = F)

reports$render("~/RStudio/Platform/insights/mka_management_profile_manual/mka_management.Rmd", open = T)


reports$render("~/RStudio/master/Platform/reports/psycholance_rmd/dashboard.Rmd", open = FALSE)

not_cleaned_env_times <- list(
  dashboard_wrapper_time = dashboard_wrapper_time,
  startup_time = startup_time,
  vb1_time = vb1_time,
  vb2_time = vb2_time,
  vb3_time = vb3_time,
  vb4_time = vb4_time,
  per_centralist_time = per_centralist_time,
  approval_time = approval_time,
  kaart_download = kaart_download,
  kaart_time = kaart_time,
  tabel_time = tabel_time,
  total_time_no_wrapper = startup_time + vb1_time + vb2_time + vb3_time + vb4_time +
    per_centralist_time + approval_time + kaart_download + kaart_time + tabel_time,
  total_time = dashboard_wrapper_time + 
    startup_time + vb1_time + vb2_time + vb3_time + vb4_time +
    per_centralist_time + approval_time + kaart_download + kaart_time + tabel_time)

summaryRprof("startup.out")

#data$count 0.96 s
summaryRprof("vb1.out")
summaryRprof("vb2.out")
summaryRprof("vb3.out")
summaryRprof("vb4.out")


summaryRprof("per_centralist.out")
summaryRprof("approval.out")
summaryRprof("task_trend")
summaryRprof("kaart.out")
summaryRprof("tabel.out")


summaryRprof("total.out")

reports$render("~/RStudio/master/Platform/reports/mka_management_profile_total/mka_management.Rmd", open = T)


reports$render("~/RStudio/master/Platform/reports/mka_management_partial/mka_management.Rmd", open = T)

reports$render("~/RStudio/master/Platform/reports/mka_management/mka_management.Rmd", open = T)



reports$render("~/RStudio/master/Platform/reports/mka_centralist/mka_centralist.Rmd", open = FALSE)


reports$render("~/RStudio/reports/modules/scenario_editor/dashboard.Rmd", open = FALSE)


reports$render("~/RStudio/reports/clients/devise/user_rights/report.Rmd",  open = TRUE) 



reports$render("~/RStudio/reports/clients/proigia/voorspellen_hap_2023/report.Rmd",  open = TRUE, output_format = "html") 
reports$render("~/RStudio/reports/clients/proigia/capaciteitstool_2023/capacity_tool.Rmd",  open = TRUE, output_format = "html")



reports$render("~/RStudio/reports/modules/simulation/dashboard.Rmd", open = F) 



reports$render("~/RStudio/Platform/insights/simulation_request/dashboard.Rmd", open = F) 

reports$render("~/RStudio/reports/clients/rav_fryslan/automatisch_statussen/dashboard.Rmd",  open = T) 







reports$render("~/RStudio/Platform/insights/a1_performance_rmd/dashboard.Rmd",  open = FALSE) 



#reports repo:
reports$render("~/RStudio/reports/modules/ambulance_logistics_edaz/dashboards/a1_performance/dashboard.Rmd",  open = FALSE) 




