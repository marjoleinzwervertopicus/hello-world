source("Library/init_analysis.R")
reports$init_rmd()

params <- list(date_filter = c(as.Date("2023-01-01"), as.Date("2023-04-10")), region = '23')

use_db <- paste0("rav_limburg_", ifelse(params$region == '23', "noord", "zuid"))
connections <- source("Library/database/database.R", local = T)$value$get_connections(use_db)
calculate_edaz <- source("Library/modules/ambulance_logistics_edaz/calculate_db.R", local = T)$value$create(connections[[use_db]])
visualize <- import("Library/visualize/visualize.R")$create()
date_utilities <- import("Library/utilities/dates.R")
time <- source("Library/utilities/time.R", local = TRUE)$value
clean_mileage <- import("Library/clients/rav_limburg_noord/ambulance_logistics_edaz/clean_mileage.R")



zuid_included_vehicle_codes_verreden_km <- c( # starts with
  "241",
  "242", ##(op dit moment nog niet in gebruik, maar waarschijnlijk wel in de toekomst)
  "2430", ##(MICU voertuigen)
  "2438" ##(Rapid Responder)
)



noord_excluded_vehicle_codes_verreden_km <- c(
  "101",
  "103",
  "104",
  "105",
  "108",
  "109",
  "110",
  "111",
  "112",
  "113",
  "115",
  "117",
  "118",
  "119",
  "120",
  "121",
  "124",
  "341",
  "342",
  "999",
  "BAS",
  "xxx",
  "23`116",
  "23000",
  "22314",
  "23140",
  "23266",
  "23303",
  "23404",
  "23506",
  "23507",
  "23508",
  "23801",
  "23802",
  "23803",
  "23804",
  "23805",
  "23806",# NEW
  "23831",
  "23999",
  "23xxx",
  "23XXX",
  "23test",
  "231106",
  "22310",
  "23998",
  "23 107"
)



all_vehicles <-
  calculate_edaz$select(calculate_column =
                          c("vehicle_code"),
                        date_filter = c(as.Date("2020-01-01"), params$date_filter[2]),
                        exclude_excluded = FALSE) %>% distinct() %>% pull(vehicle_code)



keep_vehicles <- if(params$region == '23'){
  all_vehicles[!(all_vehicles %in% noord_excluded_vehicle_codes_verreden_km)]
}else{
  grep(paste0("^(", paste0(zuid_included_vehicle_codes_verreden_km, collapse="|"), ")"), all_vehicles, value = T)
}



dataset <-
  calculate_edaz$select(calculate_column =
                          c("task_id",
                            "receive_task_datetime",
                            "receive_task_month_day",
                            "vehicle_code",
                            "exclude",
                            "task_type_name",
                            "vehicle_km_start",
                            "vehicle_km_end"),
                        date_filter = c(as.Date("2020-01-01"), params$date_filter[2]),
                        filters = list(vehicle_code =
                                         list(values = keep_vehicles,
                                              operation = "IN")),
                        exclude_excluded = FALSE)


if(params$region == '24'){
  # Some kmbegin/kmeind have duplicates
  dataset <- dataset %>%
    mutate(vehicle_km_start = as.numeric(unlist(sapply(vehicle_km_start, function(x) unique(x)))),
           vehicle_km_end = as.numeric(unlist(sapply(vehicle_km_end, function(x) unique(x)))))
}


dataset_km <-
  clean_mileage$summarize_mileage(dataset %>% filter(vehicle_code == '23341'), date_range = params$date_filter, print = TRUE) %>%
  rename(x = Maand, y = Totaal) %>% mutate(x = factor(x, c("Januari", "Februari", "Maart", "April",
                                                           "Mei", "Juni", "Juli", "Augustus", "September",
                                                           "Oktober", "November", "December"
  )), group = "Totaal")
