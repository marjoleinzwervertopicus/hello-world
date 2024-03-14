library(shiny)
library(shinyjs)
library(shinyWidgets)
source("Library/init.R")
visualize <- source("Library/visualize/visualize.R", local = T)$value$create()
db <- import("Library/database/db.R")

db_con <- db(database = "rav_drenthe", tables = "ambulance_task_edaz", single_table_name = F)

ui <- fluidPage(
  useShinyjs(),
  span(
    highchartOutput("graph")
  )
)

server <- function(input, output) {
  output$graph <- renderHighchart({
    result <- 
      db_con$count_json(time_column = "receive_task_datetime",
                        time = "yearly",
                        groups = "specialisme",
                        calculate_column = "specialisme",
                        exclude_excluded = T) |>
      ungroup() |>
      group_by(x, specialisme) |>
      mutate(y = sum(y)) |>
      distinct(x, specialisme, .keep_all = T) |>
      filter(!specialisme %in% "Pci") |>
      ungroup()
    result$specialisme[is.na(result$specialisme)] <- "Onbekend"
    
    result <- result |>
      filter(specialisme %in% c("Algemeen", "Cardiologie")) |>
      group_by(specialisme)
    
    #comment out this line to see difference with no additional tooltip
    # result$tooltip <- "test"
    
    result |>
      visualize$graph(
        interactive = T,
        theme = list(spline = list(marker = T)),
        types = list(spline = T),
        options = list(tooltip_shared = T,
                       navigator = T),
        labels = list(
          title = paste0(icon(name = "fa-info-circle",
                              class = "fa-regular",
                              title = "Pas zelf de grootte van het blauwe vlak in de tijdlijn onder de grafiek aan om de trend over een andere tijdsperiode te bekijken."),
                         " Aantal ritten per specialisme en per "),
          x = "",
          y = "Aantal ritten",
          group = "Specialisme",
          fill = "Specialisme")
      )
  })
}

shinyApp(ui = ui, server = server)