library(shiny)

ui <- HTML(paste0("<body class = 'test'><p>Your input: </p></body>"))

server <- function(input, output) {}

shinyApp(ui, server)