Sys.setlocale(locale = "en_US.utf8")

source("clients/proigia/voorspellen_hap_2023/model.R")
source("Library/init_analysis.R")
library(modeltime)
library(parsnip)
library(recipes)

week_sequence <- tibble(
  date = seq(from = ymd("2022-01-03"), 
             length.out = 55, 
             by = "1 week")) %>%
  mutate(label = format(date, "Week %-W %Y (%-d-%-m-%Y)"))




# plot_stl_diagnostics(hourly_data, datetime, value)

compare_weeks <- function(model) {
  week_sequence <- seq(from = ymd("2022-01-03"), 
               length.out = 55, 
               by = "1 week")
  
  highest_mae <- 0
  highest_week <- NULL
  lowest_mae <- 50
  lowest_week <- NULL
  
  for(week in as.character(week_sequence)) {
    mae <- test_model(model, test_week = week)$mae
    warning(week)
    warning(mae)
    
    if(mae > highest_mae) {
      highest_mae <- mae
      highest_week <- week
    }
    if(mae < lowest_mae) {
      lowest_mae <- mae
      lowest_week <- week
    }
    # warning(paste0(week, " r2: ", r2))
  }
  
  list(lowest_week = lowest_week, lowest_mae = lowest_mae, highest_week = highest_week, highest_mae = highest_mae)
}

test_model_2 <- function(model, data = test_data) {
  result_2 <- model |>
    predict(data) |>
    bind_cols(data) %>%
    select(datumtijd, actual_value = bellers_totaal, predicted_value = .pred, is_open)
  
  multi_metric <- metric_set(rmse, rsq, mae, smape)
  
  multi_metric(result_2 %>% filter(is_open), truth = actual_value, estimate = predicted_value)
  
}

  
test_model <- function(..., data = test_data %>% filter(is_open), test_week = NULL, filter_weather_na = TRUE) {
  model_table <- modeltime_table(...)

  # data <- data %>% filter(datum < as.Date("2023-01-23"))
  # 
  # data <- data %>%
  #   group_by(datum) %>%
  #   mutate(weer_gevoelstemp_max_dag = max(weer_gevoelstemp_max)) %>% ungroup()
  
  if(!is.null(test_week)) {
    #week_selection <- as.Date("2022-01-03")
    week_selection <- as.Date(test_week)
    
    data <- data %>% 
      filter(datumtijd >= as.Date(week_selection),
             datumtijd < as.Date(week_selection) + weeks(1))
  }
  
  if(filter_weather_na) {
    data <- data %>% filter(!is.na(weer_gevoelstemp_max))
  }
  
  calibration_table <- model_table %>%
    modeltime_calibrate(data, quiet = F)
  
  table <- calibration_table %>%
    modeltime_accuracy(metric_set = extended_forecast_accuracy_metric_set(), quiet = FALSE)
  # browser()
  # 
  # 
  # multi_metric <- metric_set(rmse, rsq, mae, smape)
  # predicted_value <- predict(model, data)$.pred
  # multi_metric(prediction %>% filter(datumtijd %in% open_hours), truth = data, estimate = predicted_value))
  
  
  
  table %>%
    # select(Model = .model_desc, 
    #        MAE = mae, 
    #        MAPE = mape, 
    #        MASE = mase, 
    #        SMAPE = smape, 
    #        RMSE = rmse, 
    #        RSQ = rsq) %>%
    visualize$table()
  
  table
}

forecast_model <- function(model, data = test_data %>% filter(is_open), week_selection = as.Date("2022-01-03")) {
  forecast <- data #%>%
  #   group_by(datum) %>%
  #   mutate(weer_gevoelstemp_max_dag = max(weer_gevoelstemp_max)) %>% ungroup()
  
  forecast[["prediction"]] <- predict(model, forecast)$.pred
  
  if(!is.null(week_selection)) {
  forecast <- forecast %>%
    filter(datumtijd >= as.Date(week_selection),
           datumtijd < as.Date(week_selection) + weeks(1))
  }
  
  visualize$graph(forecast %>% 
                    mutate(x = datumtijd, 
                           y = prediction, 
                           type = "Voorspelling") %>% 
                    group_by(type), 
                  theme = list(line = list(linetype = "dashed")), interactive = T, colors = "red") %>%
    visualize$graph(forecast %>% 
                      mutate(x = datumtijd, 
                             y = bellers_totaal, 
                             type = "Werkelijk") %>% 
                      group_by(type), interactive = T, colors = "black")
}


get_residuals <- function(model) {
  forecast <- test_data %>% filter(datum < as.Date("2023-01-23"))

  forecast[["prediction"]] <- predict(model, forecast)$.pred
  
  forecast <- forecast %>% mutate(difference = prediction - bellers_totaal)
  forecast
}

get_forecast_week <- function(model, day) {
  day_1_week <- floor_date(as.Date(day), unit = "week", week_start = 1)
  
  forecast_model(model, week_selection = day_1_week)
}

visualize_train_week <- function(day) {
  day_1_week <- floor_date(as.Date(day), unit = "week", week_start = 1)
  
  data <- train_data  %>%
    filter(datumtijd >= as.Date(day_1_week),
           datumtijd < as.Date(day_1_week) + weeks(1))
  
  visualize$graph(data %>% 
                    mutate(x = datumtijd, 
                           y = bellers_totaal, 
                           type = "Werkelijk") %>% 
                    group_by(type), interactive = T, colors = "black")
}


get_weather_week <- function(day) {
  day_1_week <- floor_date(as.Date(day), unit = "week", week_start = 1)
  
  test_data <- test_data %>% filter(datumtijd >= as.Date(day_1_week) - weeks(4),
         datumtijd < as.Date(day_1_week) + weeks(1))
  
  visualize$graph(
    test_data %>% 
      select(
        x = datumtijd,
        y = weer_gevoelstemp_max
      ), interactive = T,
    types = list(line = TRUE),
    colors = "red") %>%
    
  visualize$graph(
    test_data %>% 
      select(
        x = datumtijd,
        y = weer_gevoelstemp_gem
      ), interactive = T,
    types = list(line = TRUE),
    colors = "black") %>%
  
  visualize$graph(
    test_data %>% 
      select(
        x = datumtijd,
        y = weer_gevoelstemp_min
      ), interactive = T,
    types = list(line = TRUE),
    colors = "blue")
}

get_n_biggest_mistakes <- function(model, n) {
  res <- get_residuals(model)
  res <- res %>% arrange(desc(difference))
  res[1:n, ] %>% arrange(datumtijd)
}



arima_boost_diffs <- get_n_biggest_mistakes(model_fit_arima_boost_14, 20)
stlm_arima_boost_diffs <- get_n_biggest_mistakes(tbats_5, 20)
biggest_diffs_overlap <- as.Date(intersect(as.character(arima_boost_diffs$datumtijd), as.character(stlm_arima_boost_diffs$datumtijd)))

#"2022-02-05" "2022-05-02" "2022-07-09" "2022-07-30" "2022-10-08" "2022-10-22" "2022-12-31" "2023-01-28"

#2022-02-05
get_forecast_week(model_fit_arima_boost_14, as.Date("2022-02-05"))
get_forecast_week(tbats_5, as.Date("2022-02-05"))
get_weather_week("2022-02-05")


#2022-05-02, werkelijk = 0, kan dit een foutje zijn?
get_forecast_week(model_fit_arima_boost_14, as.Date("2022-04-02"))
get_forecast_week(tbats_5, as.Date("2022-05-02"))
# get_weather_week("2022-05-02")


#2022-07-09
get_forecast_week(model_fit_arima_boost_14, as.Date("2022-07-09"))
get_forecast_week(tbats_5, as.Date("2022-07-09"))
get_weather_week("2022-07-09")


#16, 17, 18 april 2022 allemaal onderschat





#24, 25 (za, zo) december onderschat -> feestdag naam ipv is_feestdag?
visualize_train_week("2019-12-25")
get_forecast_week(model_fit_arima_boost_14, "2022-12-25")

get_forecast_week(model_fit_arima_boost_feestdag_weekend_int, "2022-12-25")
get_weather_week("2022-12-25")


#19, 20 feb, onderschat

#16, 17, 18 april onderschat



res <- get_residuals(model_fit_arima_boost_14)

res2 <- res
res2$difference <- res2$difference + 0.65087

big_diffs <- res[abs(res$difference) > 20, ]
diff_summary <- summarize(big_diffs %>% group_by(datum), n = n())


big_diff_dates <- diff_summary$datum[diff_summary$n > 4]
date_5_plus_big_diffs <- big_diffs[big_diffs$datum %in%big_diff_dates, ]


nrow(big_diffs[big_diffs$datum_weekdag %in% c("Saturday", "Sunday") | big_diffs$is_feestdag, ])

visualize$graph(res %>% rename(x = datumtijd, y = difference), interactive = T)

#are there significant correlations?
acf(res$difference[!is.na(res$difference)])

#p value > 0.05 means independent residuals, which means correct model
Box.test(res$difference, type="Ljung-Box")


test_data[test_data$datum == as.Date("2022-04-16"), ]

tbats_res$difference <- abs(tbats_res$difference)
tbats_res %>% select(x = datumtijd, y = difference) %>% visualize$graph(options = list(line = TRUE), interactive = T)


#arima has lots of negative values in forecast
forecast_model(model_fit_arima_9, week_selection = NULL)
arima_res <- get_residuals(model_fit_arima_9)
mean_1 <- mean(abs(arima_res$difference))
# arima_res$difference <- map_dbl(arima_res$difference, ~max(., 0))
# mean_2 <- mean(abs(arima_res$difference), na.rm = T)



forecast_model(tbats_5, week_selection = NULL)


#all of the peaks seem to be low
forecast_model(model_fit_arima_boost_14, week_selection = NULL)
arima_boost_res <- get_residuals(model_fit_arima_boost_14)
mean_1 <- mean(abs(arima_boost_res$difference))

#also low peaks for is_open = TRUE
forecast_model(model_fit_arima_boost_14_open_only, week_selection = NULL,data = test_data %>% filter(is_open))



