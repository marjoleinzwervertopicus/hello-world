source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")

db_app <- db_connect("geography", preset = "postgres_application_admin")
db_app_new <- db_connect("geography", preset = "postgres_application_new_admin")

table_names <- c(
  "bag_adres",
  "bag_adres_feb_25",
  "bag_adres_mei_23",
  "country_shape",
  "coverage_shape",
  "coverage_tasks_limburg",
  "district_shape",
  "drive_time_ambulance",
  "drive_time_car",
  "hex_grid",
  "lazk_regions",
  "municipality_shape",
  "neighborhood_shape",
  "place_info",
  "planet_osm_line",
  "planet_osm_nodes",
  "planet_osm_point",
  "planet_osm_polygon",
  "planet_osm_rels",
  "planet_osm_roads",
  "planet_osm_ways",
  "province_shape",
  "rav_region_shape",
  "rav_regions",
  "residential_area_shape",
  "roaz_region_shape",
  "square_100m_shape",
  "zipcode_4_info",
  "zipcode_4_shape"
)

for(table_name in table_names) {
  message("Copy table ", table_name, " from application to application_new")
  db_app$table(table_name) |> 
    db_app_new$write(table_name, overwrite = TRUE, copy_structure = TRUE)
}

db_app$disconnect()
db_app_new$disconnect()
