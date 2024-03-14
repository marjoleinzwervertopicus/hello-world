source("Library/rmd/init_dashboard.R")

params <- list(municipality = "Pijnacker-Nootdorp", validation = T)

data <- 
  data_sources$connect(
    paste0(
      "db jb_lorenz mmr_financial_overview", 
      if(params$validation) "_validation")
  )

calculate <- import("Library/clients/jb_lorenz/mmr/calculate_db.R")

jb_config <- list(
  graph_colors = c("#02C663", "#007432"),
  map_colors = colors("#00A754", 5),
  municipality = params$municipality
)
jb_config$municipality_key <- unique(data$select(filters = list(region_name = jb_config$municipality, region_type = "GM"), calculate_column = "region_key")$region_key)


result_graph_bijstand_clienten_duizend <- 
  calculate$select_indicator_finance(data = data,
                                     theme = "Participatie",
                                     indicator = "participatie_clienten_bijstand",
                                     value_type = "per duizend",
                                     municipality_key = jb_config$municipality_key,
                                     region_type = "GM",
                                     filter_max_year = F)


connections$customer$get("SELECT indicator, value_type, region_name FROM mmr_financial_overview_validation WHERE ( ( ( (indicator IN ('jeugd_clienten_totaal') )) and municipality_key IN ('GM1926', 'GM0677') ) and region_type IN ('GM') )")


result_graph_ioaw_clienten_duizend <- 
  calculate$select_indicator_finance(data = data,
                                     theme = "Participatie",
                                     indicator = "participatie_clienten_ioaw",
                                     value_type = "per duizend",
                                     municipality_key = jb_config$municipality_key,
                                     region_type = "GM",
                                     filter_max_year = F) 
