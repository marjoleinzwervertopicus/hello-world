source("Library/init.R")
source("deploy/init.R")


render("~/RStudio/reports/clients/rav_drenthe/dashboards/medewerker_rmd/dashboard.qmd", output_format = "html") |>
  open()
