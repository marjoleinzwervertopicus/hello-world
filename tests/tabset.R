# library(shiny)
# library(shinyjs)
source("Library/init_analysis.R")



ui <- div(
  navbarPage(
    tabPanel(title = "Start", actionButton("test", "Test")),
    tabPanel(title = "Start2", div("start2")),
    
    title = "Devise",
    id = "menu")
)



server <- function(input, output, session) {
  observeEvent(input$menu, {
    # sink()
    # # stop("test")
    # print("test")
    warning("test")
  })
  
  observeEvent(input$test, {
    # browser()
    # sink()
    # # stop("test")
    # print("test2")
    warning("test2")
    warning(input$menu)
  })
}


shinyApp(ui, server)