source("Library/init.R")
prepare <- import("Library/modules/ambulance_logistics_edaz/prepare_script.R")

result <- prepare("rav_drenthe", c(ymd("2024-01-01"), ymd("2024-01-07")), dry_run = TRUE)

saveRDS(result, "result_new.RDS")
saveRDS(result, "result_old.RDS")
saveRDS(result, "result_new.RDS")


result_old <- readRDS("result_old.RDS")
result_new <- readRDS("result_new.RDS")
result_new_mistake <- readRDS("result_new_mistake.RDS")


identical(result_old, result_new)
summary(arsenal::comparedf(result_old, result_new))


vehicle_type_prepare <- source("~/RStudio/reports/Library/preparation/prepare.R")$value$get_vehicle_type

dataset <- tibble(vehicle_code = 10000 + (1:1000))
vehicle_types_old <- vehicle_type_prepare(dataset = dataset, vehicle_code = "vehicle_code")
vehicle_types_new <- vehicle_type_prepare(dataset = dataset, vehicle_code_column = "vehicle_code")
identical(vehicle_types_old, vehicle_types_new)
