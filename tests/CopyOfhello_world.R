library(shiny)
library(shinyjs)
library(shinyWidgets)


ui <- fluidPage(
  useShinyjs(),
  span(
    radioGroupButtons(
      "date_zoom",
      "",
      choices = c(Jaar = "yearly", Kwartaal = "quarterly", Maand = "monthly", Week = "weekly", Dag = "daily")
    ),
    class = "date-zoom"
  )
)

server <- function(input, output) {
  onclick("date_zoom", {
    print("click")
    print(input[["date_zoom"]])
  })
  
  observeEvent(input$date_zoom, {
    print("click observe")
    print(input[["date_zoom"]])
  }, ignoreInit = TRUE)
}

shinyApp(ui = ui, server = server)