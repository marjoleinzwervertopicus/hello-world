# source("deploy/init.R")
# render("modules/ambulance_logistics_edaz/dashboards/production/dashboard.qmd", output_format = "shiny_prerendered") |> open()
# 

source("Library/rmd/init_dashboard.R")
db <- import("Library/database/db.R")
config <- list(client = "rav_drenthe")
db_con <- db(database = config$client, tables = "ambulance_task_edaz", single_table_name = F)
input <- list(selected_date_filter = c(as.Date("2023-01-01"), as.Date("2024-01-31")))
time <- import("Library/utilities/time.R")
color_pal <- import("Library/visualize/color_pal.R")()

valuebox <- import("Library/visualize/valuebox.R")

station_names <-
  db_con$count(groups = "station_name") |> filter(!is.na(station_name)) |> pull(station_name)


categories <- files$load_files(paste0("Library/clients/", 
                                      config$client,
                                      "/ambulance_logistics_edaz/categories.csv"),
                               all_characters = T)


result <-
  db_con$average(
    time_column = "receive_task_datetime",
    date_filter = input$selected_date_filter,
    # filters = c(filter_category(),
    #             list(station_name = filter_station_name())),
    time = "monthly",
    calculate_column = "treatment_duration",
    exclude_outliers = T
  ) |>
  arrange(x)

result |>
  visualize$graph(
    interactive = T,
    types = list(spline = T),
    options = list(duration = T),
    # colors = color,
    labels = list(y = "Tijdsduur")
  ) |>
  hc_add_theme(hc_theme_sparkline()) |>
  hc_chart(plotBackgroundColor = F) |>
  hc_xAxis(visible = F)


# get_valuebox_average <- function(calculate_column, title, icon_name, icon_color) {
  # result <-
  #   db_con$average(
  #     time_column = "receive_task_datetime",
  #     date_filter = input$selected_date_filter,
  #     filters = c(
  #       list(exclude = FALSE)#,
  #       # list(station_name = station_names)
  #     ),
  #     calculate_column = "treatment_duration",
  #     exclude_outliers = T
  #   )
  # time$convert_to_time(result$y)
  # valuebox(
  #   title = "title",
  #   value = time$convert_to_time(result$y),
  #   value_diff = NULL,
  #   add_value_diff_icon = F,
  #   # icon_name = icon_name,
  #   # icon_color = icon_color,
  #   class = NULL
  # )
  
  # result |>
  #   visualize$graph(
  #     interactive = T,
  #     types = list(spline = T),
  #     options = list(duration = T),
  #     colors =  color_pal("blue"),
  #     labels = list(y = "Tijdsduur")
  #   )
# }


#terugkeertijd
# get_valuebox_average(
#   calculate_column = "move_to_station_duration",
#   title = "Gemiddelde terugkeertijd",
#   icon_name = "fa-duotone fa-warehouse",
#   icon_color = color_pal("lime")
# )