library(shiny)

ui <- fluidPage(
  tags$script("window.document.addEventListener('DOMContentLoaded', function (_event) {
    debugger;
  })"),
  sidebarLayout(
    sidebarPanel(
      # This input will be used to dynamically generate HTML content
      textInput("input_text", "Enter Text")
    ),
    mainPanel(
      # This is where the dynamically generated UI will be displayed
      uiOutput("dynamic_ui")
    )
  )
)

server <- function(input, output) {
  # Define a reactive expression for dynamically generated UI
  output$dynamic_ui <- renderUI({
    # Use HTML with a body tag
    HTML(paste0("<body><p>Your input: ", input$input_text, "</p></body>"))
  })
}

shinyApp(ui, server)