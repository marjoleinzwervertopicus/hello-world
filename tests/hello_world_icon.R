library(shiny)
library(shinyjs)
library(shinyWidgets)


ui <- fluidPage(
  useShinyjs(),
  tags$script(src = "https://kit.fontawesome.com/cbd54b6f03.js", crossorigin = "anonymous"),

  tags$link(rel = "stylesheet", href = "https://pro.fontawesome.com/releases/v5.3.1/css/all.css",
            integrity = "sha384-9ralMzdK1QYsk4yBY680hmsb4/hJ98xK3w0TIaJ3ll4POWpWUYaA2bRjGGujGT8w",
            crossorigin = "anonymous", type="text/css"),
  span(
    div(icon("info-circle"),
        # icon("fas fa-info-circle"),
        
        # icon("fa-info-circle", title = "test")
        # icon("info", class = "fa-regular", title = "test")
        icon("cat-space"),
        )
  )
)

server <- function(input, output) {

}

shinyApp(ui = ui, server = server)