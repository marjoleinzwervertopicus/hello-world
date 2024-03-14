source("Library/rmd/init_dashboard.R")

data <- 
  data_sources$connect(
    paste0(
      "db jb_lorenz mmr_municipalityscan_validation")
  )

calculate <- import("Library/clients/jb_lorenz/mmr/calculate_db.R")

dataset <-
  calculate$select_theme_scan(data = data,
                              municipality = c("Hulst", "Terneuzen"),
                              region_type = "GM",
                              benchmark = T)


dataset |> filter(indicator %in% "Mantelzorgontvanger")


dataset %>%
  filter(indicator %in% "Eenzaamheid",
         region_name %in% c(jb_config$municipality, 
                            input$select_input_municipality, 
                            "Nederland")) %>%
  mutate(region_name = factor(region_name,
                              levels = c(jb_config$municipality, 
                                         input$select_input_municipality, 
                                         "Nederland")))



dataset %>%
  filter(indicator %in% "KinderenArmoede",
         region_name %in% c("Hulst", 
                            "Terneuzen", 
                            "Nederland")) %>%
  mutate(region_name = factor(region_name,
                              levels = c(jb_config$municipality, 
                                         input$select_input_municipality,
                                         "Nederland"))) 