library(shiny)
library(shinyjs)
source("Library/init_analysis.R")



ui <- div(
  useShinyjs(),
  DTOutput("basis_score")
)



server <- function(input, output, session) {
  output$basis_score <- renderDT(
  visualize$table(tibble(x = 1), table_format = "dt")
  )
}


shinyApp(ui, server)