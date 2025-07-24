source("Library/rmd/init_dashboard.R")

data <- 
  data_sources$connect(
    paste0(
      "db jb_lorenz mmr_municipalityscan_validation")
  )

calculate <- import("Library/clients/jb_lorenz/mmr/calculate_db.R")

dataset <-
  calculate$select_theme_scan(data = data,
                              municipality = c("Pijnacker-Nootdorp", "Terneuzen"),
                              region_type = "GM",
                              benchmark = T)

previous_indicators <- readRDS("~/RStudio/hello-world/scripts/jb_lorenz_dataset_indicatoren.RDS")

missing_indicators <- previous_indicators[!previous_indicators %in% dataset$indicator]
missing_indicators

# participatie_clienten_bijstand



dataset <-
  calculate$select_theme_scan(data = data,
                              municipality = c("Alphen aan den Rijn"),
                              region_type = "GM",
                              benchmark = T)

dataset$indicator
