source("Library/calculate/scenario/scenario_toolkit.R")
resources <- resources_load("Library/clients/rav_fryslan/resources/resource_table_2021.csv", process = T)

resources <- resources |> select(
  -link_chain,
  -inherit_location,
  -shift_text,
  -shift_hours,
  -codes,
  -hours_week,
  -fte,
  -coverage_shapes
  
) |> mutate(active_from = as.Date("2021-01-01"), scenario_id = 24)

saveRDS(resources, "resources.RDS")

source("Library/init.R") 
database <- import("Library/database/database.R")
connections <- database$get_connections("rav_fryslan")

connections$customer$get("SELECT * FROM resource WHERE scenario_id = 24")

connections$customer$insert_table_unsafe("resource", resources)
