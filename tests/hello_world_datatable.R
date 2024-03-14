library(shiny)
library(shinyjs)
library(shinyWidgets)


ui <- fluidPage(
  useShinyjs(),
  span(
    dataTableOutput("table")
  )
)

server <- function(input, output) {
  output$table <- renderDataTable({
    datatable(tibble(x = character(0)))
  })
}

shinyApp(ui = ui, server = server)