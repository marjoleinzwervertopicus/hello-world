source("Library/init.R")
# 
# library(db)
# connections_dev <- db_connect("geography", preset = "postgres_development_server")
# connections_dev$query("SHOW enable_bitmapscan")
# connections_dev$query("SHOW random_page_cost")
# connections_dev$query("SHOW effective_cache_size")
# connections_dev$query(" ANALYZE bag_adres")
# 
# connections_dev$query("SELECT COUNT(DISTINCT(postcode)) FROM bag_adres")
# 
# connections_dev$query("SELECT COUNT(*) FROM bag_adres")
# stats_dev <- connections_dev$query("SELECT attname, n_distinct, most_common_vals FROM pg_stats WHERE tablename = 'bag_adres';")
# 
# 
# indices_dev <- connections_dev$query("SELECT schemaname, tablename, indexname, indexdef FROM pg_indexes WHERE tablename = 'bag_adres';")
# connections_dev$disconnect()
# 
# connections_app <- db_connect("geography", preset = "postgres_application_server")
# connections_app$query("SHOW enable_bitmapscan")
# connections_app$query("SHOW random_page_cost")
# connections_app$query("SHOW effective_cache_size")
# stats_app <- connections_app$query("SELECT attname, n_distinct, most_common_vals FROM pg_stats WHERE tablename = 'bag_adres';")
# connections_app$query("SELECT COUNT(*) FROM bag_adres")
# connections_app$query("SELECT COUNT(DISTINCT(postcode)) FROM bag_adres")
# 
# 
# indices_app <- connections_app$query("SELECT schemaname, tablename, indexname, indexdef FROM pg_indexes WHERE tablename = 'bag_adres';")
# connections_app$disconnect()
# 
# identical(indices_app, indices_dev)

dataset_ijsselland <- readRDS("~/RStudio/hello-world/scripts/dataset_ijsselland.RDS")

connections <- import("Library/database/database.R")$get_connections("geography", persistent = F, host = "postgres_application_server")$geography
geography <- source("Library/calculate/geography.R", local = T)$value$create(connections)
dataset <- geography$geocode_batch(dataset_ijsselland, hex_grid = T, bind = T, prefix = "incident_", search_prefix = "incident_", return = c("latitude", "longitude", "place", "province", "municipality", "housenumber"))
connections$disconnect()
