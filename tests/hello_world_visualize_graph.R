library(shiny)
library(shinyjs)
library(shinyWidgets)
library(highcharter)
source("Library/init.R")
visualize <- source("Library/visualize/visualize.R", local = T)$value$create()


ui <- fluidPage(
  useShinyjs(),
  span(
    highchartOutput("graph")
  )
)

# x <- rep(seq(
#   from = ymd_hms("2022-01-01 00:00:00"),
#   to =  ymd_hms("2023-01-01 00:00:00"),
#   by = "1 hour"), 2)
# 
# y <- c(rep(10, length(x) / 2), rep(20, length(x) / 2))
# 
# group <- c(rep("a", length(x) / 2), rep("b", length(x) / 2))

result123 <- readRDS("~/RStudio/hello_world/tests/spline_graph_tibble.RDS")

server <- function(input, output) {
  output$graph <- renderHighchart({
    result123 |>
      visualize$graph(interactive = T,
                      theme = list(spline = list(marker = T)),
                      types = list(spline = T),
                      options = list(navigator = T,
                                     export_enabled = T)) |>
      hc_chart(plotBackgroundColor = F) |>
      hc_xAxis(visible = F) |>
      hc_yAxis(visible = F) |>
      hc_navigator(enabled = F) |> hc_exporting(enabled = TRUE)
  })
}

shinyApp(ui = ui, server = server)