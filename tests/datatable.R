library(shiny)
library(shinyjs)
library(DT)
source("Library/init_analysis.R")



ui <- div(
  useShinyjs(),
  DTOutput("hr_scenario_table")
)



server <- function(input, output, session) {
  # state <- import("R/platform/state.R")$create(input, output, session, make_db_connection = TRUE)
  output[["hr_scenario_table"]] <- DT::renderDataTable({
    datatable(
      tibble(x = character(0)),
      options = list(
        language = list(url = '//cdn.datatables.net/plug-ins/1.13.4/i18n/nl-NL.json'),
        scrollX = T
      )
    )
  }, server = FALSE)
}


shinyApp(ui, server)