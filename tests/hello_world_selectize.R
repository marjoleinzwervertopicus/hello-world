library(shiny)
library(shinyjs)
library(shinyWidgets)


ui <- fluidPage(
  tags$head(
    # tags$style(type="text/css", "label.control-label, .selectize-control.single{ display: table-cell; text-align: center; vertical-align: middle; } .form-group { display: table-row;}")
    tags$style(type="text/css", "label.control-label{display: table-cell; padding-right: 5px} .form-group.shiny-input-container{ display: table-row}")
    
  ),
  span(
    # fluidRow(HTML("<b>Tijdsduur:</b>"),
    selectInput("selected_tijdsduur", "Tijdsduur:",
                choices = c("a1" = "a1",
                            "a2" = "a2",
                            "geen waarde" = NA),
                selected = NA,
                multiple = F)#)
  )
)

server <- function(input, output) {
}

shinyApp(ui = ui, server = server)