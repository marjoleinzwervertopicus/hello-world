source("Library/rmd/init_dashboard.R")

data <- 
  data_sources$connect(
    paste0(
      "db jb_lorenz mmr_financial_overview")
  )
calculate <- import("Library/clients/jb_lorenz/mmr/calculate_db.R")

#Bijstand ----
# TAB 1: Aantal cliënten ----
result_graph_bijstand_clienten <- 
  calculate$select_indicator_finance(data = data,
                                     theme = "Participatie",
                                     indicator = "participatie_clienten_bijstand",
                                     value_type = "aantal",
                                     municipality_key = "GM0677",
                                     region_type = "GM",
                                     filter_max_year = F)
