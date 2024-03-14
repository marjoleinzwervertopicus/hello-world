source("Library/init.R")
files <- import("Library/utilities/files.R")

trained_model_path <- "/home/shared/data/clients/proigia/trained_models/"
my_model_paths <- list.files(trained_model_path, pattern = "^maio_.*\\.rds$", full.names = T)

test_data <- readRDS("/home/shared/data/clients/proigia/test_data_per_uur.rds") %>% filter(is_open, datum < as.Date("2023-01-01"))
test_data_2 <- readRDS("/home/shared/data/clients/proigia/test_data_per_uur.rds") %>% filter(datum < as.Date("2023-01-01"))


test_model <- function(model) {
  model_table <- modeltime_table(model)
  
  calibration_table <- model_table %>%
    modeltime_calibrate(test_data, quiet = F)
  
  calibration_table %>%
    modeltime_accuracy(metric_set = extended_forecast_accuracy_metric_set(), quiet = FALSE)
  
}

test_model_2 <- function(model) {
  result_2 <- model |>
    predict(test_data_2) |>
    bind_cols(test_data_2) %>%
    select(datumtijd, actual_value = bellers_totaal, predicted_value = .pred, is_open)

  result <- model |>
    predict(test_data) |>
    bind_cols(test_data) %>%
    select(datumtijd, actual_value = bellers_totaal, predicted_value = .pred, is_open)
  
  multi_metric <- metric_set(rmse, rsq, mae, smape)
  
  browser()
  multi_metric(result, truth = actual_value, estimate = predicted_value)
  multi_metric(result_2 %>% filter(is_open), truth = actual_value, estimate = predicted_value)
  
}

for(model_path in my_model_paths) {
  model <- readRDS(model_path)
  prediction <- predict(model, test_data)$.pred
  results_tibble <- tibble(datumtijd = test_data$datumtijd, actual_value = test_data$bellers_totaal, predicted_value = prediction)
  result_csv_path <- paste0("/home/shared/data/clients/proigia/trained_models/", gsub(".rds$", "", basename(model_path)), "_prediction.csv")
  files$write_csv(results_tibble, result_csv_path)
  
  load <- files$load_file(result_csv_path, all_characters = F)
  multi_metric <- metric_set(rmse, rsq, mae, smape)
  scores_new <- multi_metric(load, truth = actual_value, estimate = predicted_value)
  scores_old <- test_model(model) %>% select(rmse, rsq, mae, smape)
  
  if(!is.na(scores_old$rsq) && scores_new$.estimate[2] - scores_old$rsq > 1e-15) browser()
  print(paste0(model_path, ": ", scores_old$rsq))
  test_model_2(model)
}

run_all_models <- function() {
  good_model_paths <- c(
    "~/RStudio/reports/clients/proigia/voorspellen_hap_2023/models/sarimax_1.R",
    "~/RStudio/reports/clients/proigia/voorspellen_hap_2023/models/arima_boost_day_1.R",
    "~/RStudio/reports/clients/proigia/voorspellen_hap_2023/models/stml_arima_1.R",
    "~/RStudio/reports/clients/proigia/voorspellen_hap_2023/models/nnetar_1.R"
  )
  
  
}










