library(jsonlite)

reactives_list <- list(calculate_functions = list(values = "count"), calculate_location = list(values = "Library/modules/ambulance_logistics_edaz/calculate_db.R"), table_name = list(values = "ambulance_task_edaz"), groups = list(values = "a1_performance"))

# reactives_list$groups <- reactives_list$groups$serialize()
# if("pivot_groups" %in% names(reactives_list)) reactives_list$pivot_groups <- reactives_list$pivot_groups$serialize()

bi_config <- list(dashboard_code = "tools_drilldown", reactives = reactives_list, active_tab = "group_tab")

bi_config_url_encoded <- URLencode(toJSON(bi_config, null = "null"), reserved = TRUE)


#%7B%22dashboard_code%22%3A%5B%22tools_drilldown%22%5D%2C%22reactives%22%3A%7B%22calculate_functions%22%3A%5B%22count%22%5D%2C%22calculate_location%22%3A%5B%22Library%2Fmodules%2Fambulance_logistics_edaz%2Fcalculate_db.R%22%5D%2C%22table_name%22%3A%5B%22ambulance_logistics_edaz%22%5D%7D%2C%22active_tab%22%3A%5B%22group_tab%22%5D%7D