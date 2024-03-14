source("Library/calculate/scenario/scenario_toolkit.R")
files <- source("Library/utilities/files.R")$value
resources <- resources_load("clients/rav_limburg/analyse_standplaatsen_2023/resources_azln.csv", process = T)

resources |> 
  filter(type == "Station") |> 
  separate_wider_delim(location, " ", names = c("zipcode", "housenumber"), cols_remove = FALSE) |>
  mutate(
    provider_code = "04",
    active = TRUE,
    zipcode_4 = str_sub(zipcode, end = 4)) |>
  select(name, code = id, provider_code, zipcode = zipcode_4, housenumber, address = zipcode, latitude, longitude, active) |>
  files$write_csv("modules/ambulance_logistics_edaz/dashboards/production/stations_rav_limburg_noord.csv", sep = ";")


source("Library/calculate/scenario/scenario_toolkit.R")
resources <- resources_load("clients/rav_limburg/analyse_standplaatsen_2023/resources_ggdzl.csv", process = T)

resources |> 
  filter(type == "Station") |> 
  separate_wider_delim(location, " ", names = c("zipcode", "housenumber"), cols_remove = FALSE) |>
  mutate(
    provider_code = "04",
    active = TRUE,
    zipcode_4 = str_sub(zipcode, end = 4)) |>
  select(name, code = id, provider_code, zipcode = zipcode_4, housenumber, address = zipcode, latitude, longitude, active) |>
  files$write_csv("modules/ambulance_logistics_edaz/dashboards/production/stations_rav_limburg_zuid.csv", sep = ";")
