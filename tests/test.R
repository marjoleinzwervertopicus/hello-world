library(tidymodels)
library(modeltime)

train_data <- readRDS("/home/shared/data/clients/proigia/train_data_per_uur.rds")

add_feestdag_columns <- function(data) {
  data %>% 
    mutate(is_feestdag_gesloten_uur = as.factor(is_feestdag & !datum_weekdag %in% c("Saturday", "Sunday") & datum_uur %in% c(8:16)),
           is_feestdag_open_uur = as.factor(is_feestdag & (datum_weekdag %in% c("Saturday", "Sunday") | datum_uur %in% c(17:23, 0:7))))
}


sarimax_week_feestdag_open_closed <- arima_reg(seasonal_differences = 1, seasonal_period = "1 week") %>%
  set_engine("arima") %>%
  fit(bellers_totaal ~ datumtijd + is_feestdag_gesloten_uur + is_feestdag_open_uur, train_data %>% add_feestdag_columns())

saveRDS(sarimax_week_feestdag_open_closed, "~/RStudio/trained_models/sarimax_week_feestdag_open_closed.RDS")