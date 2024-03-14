
html <- div(gsub("<head>.*</head>", "", includeHTML("reports//user_rights_stats/report.html")), class = "html-report" )


ui <- div(
  class = NULL,
  fluidRow(class = "html_report",
           shinydashboard::box(
             width = 12,
             html
           )))



server <- function(input, output, session) {
}


shinyApp(ui, server)
