library(shiny)
library(shinyjs)
library(shinyWidgets)

visualize <- source("Library/visualize/visualize.R", local = T)$value$create()


ui <- fluidPage(
  useShinyjs(),
  span(
    uiOutput("table")
  )
)

server <- function(input, output) {
  output$table <- renderUI({
    visualize$table(tibble(x = character(0)), table_format = "dt") %>% HTML()
  })
}

shinyApp(ui = ui, server = server)