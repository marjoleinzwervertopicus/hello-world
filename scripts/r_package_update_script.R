packages_available_to_update <- old.packages(repos = "https://cloud.r-project.org") |> 
  as_tibble() |> 
  select(name = Package, installed_version = Installed, available_version = ReposVer) |> 
  arrange(tolower(name))

explicit_package_names <- c("withr", "shiny", "blastula", "bookdown", "bslib", "bsplus", "DBI",
                            "DT", "flexdashboard", "fontawesome", "formattable", "gganimate", 
                            "ggrepel", "highcharter", "leaflet", "kableExtra", "openxlsx", 
                            "patchwork", "plyr", "rapidjsonr", "rhandsontable", "rmapshaper",
                            "rmarkdown", "RMySQL", "RPostgres", "RPostgreSQL", "rprojroot",
                            "shinyBS", "shinydashboard", "shinyFeedback", "shinyjs", "shinyWidgets",
                            "sodium", "slackr", "stringr", "tidyverse", "xgboost",
                            "prophet", "tidymodels", "modeltime", "timetk", "reticulate",
                            "plumber", "httr2", "webshot", "quarto", "bsicons",
                            "odbc", "pool", "duckdb", "AzureTableStor", "sf",
                            "languageserver", "purrr", "tidyjson", "Rdiagnosislist")



lines <- readLines("~/Docker/devise-ubuntu/setup/install_r_packages.sh")

lines <- lines[grepl("install_version", lines)]

# Extract the text between single quotes after install_version(
package_names <- gsub(
  ".*install_version\\('([^']+)'.*",
  "\\1",
  lines
)



packages_to_update <- packages_available_to_update |> filter(name %in% explicit_package_names)

#content of csv can be copies 
confluence_table <- packages_to_update |> select (naam = name, `oude versie` = installed_version, `nieuwe versie` = available_version)
write.table(confluence_table, "confluence_table.csv", sep = ";", row.names = F)

