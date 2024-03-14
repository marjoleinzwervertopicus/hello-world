source("Library/init_analysis.R")
roaz <- import("Library/clients/roaz_aznn/parse_roaz_regional.R")
connection_geo <- import("Library/database/database.R")$get_connections(c("geography"), persistent = FALSE)
zipcode_4_info <- connection_geo$geography$get("SELECT * FROM zipcode_4_info")

# params
dry_run <- TRUE
sfx <- if(dry_run) "_test2" else "" 
skip_categories_seh <- c("Kinderen", "Obstetrie")

# ===================== SEHs =====================
roaz$create_roaz_table(category = "seh", suffix = sfx)
roaz$load_config('Nij Smellinghe') |> roaz$load_file() |> roaz$add_mappers() |> roaz$process_datetimes() |> roaz$prepare_seh(zipcode_4_info = zipcode_4_info) |> filter(!(type_acute_bezoek %in% skip_categories_seh)) |> roaz$write_roaz_table("seh", suffix = sfx)
roaz$load_config('Martini Ziekenhuis') |> roaz$load_file() |> roaz$add_mappers() |> roaz$process_datetimes() |> roaz$prepare_seh(zipcode_4_info = zipcode_4_info) |> filter(!(type_acute_bezoek %in% skip_categories_seh)) |> roaz$write_roaz_table("seh", suffix = sfx)
roaz$load_config('Wilhelmina Ziekenhuis Assen') |> roaz$load_file() |> roaz$add_mappers() |> roaz$process_datetimes() |> roaz$prepare_seh(zipcode_4_info = zipcode_4_info) |> filter(!(type_acute_bezoek %in% skip_categories_seh)) |> roaz$write_roaz_table("seh", suffix = sfx)
roaz$load_config('Ommelander Ziekenhuis Groningen') |> roaz$load_file() |> roaz$add_mappers() |> roaz$process_datetimes() |> roaz$prepare_seh(zipcode_4_info = zipcode_4_info) |> filter(!(type_acute_bezoek %in% skip_categories_seh)) |> roaz$write_roaz_table("seh", suffix = sfx)
roaz$load_config('Tjongerschans') |> roaz$load_file() |> roaz$add_mappers() |> roaz$process_datetimes() |> roaz$prepare_seh(zipcode_4_info = zipcode_4_info) |> filter(!(type_acute_bezoek %in% skip_categories_seh)) |> roaz$write_roaz_table("seh", suffix = sfx)
roaz$load_config('Medisch Centrum Leeuwarden') |> roaz$load_file() |> roaz$add_mappers() |> roaz$process_datetimes() |> roaz$prepare_seh(zipcode_4_info = zipcode_4_info) |> filter(!(type_acute_bezoek %in% skip_categories_seh)) |> roaz$write_roaz_table("seh", suffix = sfx)
roaz$load_config('Antonius') |> roaz$load_file() |> roaz$add_mappers() |> roaz$process_datetimes() |> roaz$prepare_seh(zipcode_4_info = zipcode_4_info) |> filter(!(type_acute_bezoek %in% skip_categories_seh)) |> roaz$write_roaz_table("seh", suffix = sfx)
roaz$load_config('Treant') |> roaz$load_file() |> roaz$add_mappers() |> roaz$process_datetimes() |> roaz$prepare_seh(zipcode_4_info = zipcode_4_info) |> filter(!(type_acute_bezoek %in% skip_categories_seh)) |> roaz$write_roaz_table("seh", suffix = sfx)
# speciaal geval - eigen specialisme mapper
spec_map <- files$load_file("Library/clients/roaz_aznn/mappers/specialisme.csv")
spec_map <- spec_map[spec_map$locatie == 'Universitair Medisch Centrum Groningen',] |> select(any_of(c("from", "to")))
roaz$load_config('Universitair Medisch Centrum Groningen') |> roaz$load_file() |> roaz$add_mappers() |> roaz$process_datetimes() |> roaz$prepare_seh(zipcode_4_info = zipcode_4_info, specialism_mapper = spec_map) |> filter(!(type_acute_bezoek %in% skip_categories_seh)) |> roaz$write_roaz_table("seh", suffix = sfx)
