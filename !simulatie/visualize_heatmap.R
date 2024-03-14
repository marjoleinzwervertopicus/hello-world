source("Library/init.R")
library(highcharter)
visualize <- import("Library/visualize/visualize.R")$create()


heatmap_results <- matrix_results
heatmap_results <- heatmap_results %>% select(capacity, speed, a1_performance)
heatmap_results <- mutate(heatmap_results, across(everything(), as.numeric))
cap_labels <- unique(heatmap_results$capacity)
cap_labels <- cap_labels[order(cap_labels)]
speed_labels <- unique(heatmap_results$speed)
speed_labels <- speed_labels[order(speed_labels)]


heatmap_results$capacity <- map_int(heatmap_results$capacity, ~which(. == cap_labels))
heatmap_results$speed <- map_int(heatmap_results$speed, ~which(. == speed_labels))

test_heatmap_data <- tibble(capacity = c(rep(1, 10), rep(2, 10), rep(3, 10), rep(4, 10), rep(5, 10), rep(6, 10), rep(7, 10), rep(8, 10), rep(9, 10), rep(10, 10)), speed = rep(seq.int(1, 10, 1), 10))
test_heatmap_data <- test_heatmap_data %>% mutate(a1_performance = capacity * speed)
# test_heatmap_data <- test_heatmap_data %>% group_by(capacity, speed)
# visualize$graph(test_heatmap_data, types = list(raster = TRUE), interactive = TRUE)


graph <- highchart()

color_stops <- list(
  # list(0, "red"),
  list(0, "orange"),
  list(1, "green")
)

graph %>%
  hc_add_series(data = heatmap_results %>% mutate(a1_performance = round(a1_performance, digits = 2)), 
                mapping = hcaes(x = capacity, y = speed, value = a1_performance), 
                type = "heatmap") %>%
  hc_colorAxis(stops = color_stops) %>%
  hc_xAxis(title = list(text = "capaciteit (kWh)"), categories = c(0, cap_labels)) %>%
  hc_yAxis(title = list(text = "laadsnelheid (kW)"), categories = c(0, speed_labels)) %>%
  hc_legend(title = list(text = "verschil in A1-prestatie (%-punt)")) %>%
  hc_title(text = "Verschil in A1-prestatie per laadsnelheid en capaciteit") %>%
  hc_plotOptions(heatmap = list(dataLabels = list(enabled = TRUE, format = "{point.value}"))) %>%
  hc_exporting(enabled = TRUE)


# 
# hchart(
#   test_heatmap_data, 
#   "heatmap", 
#   hcaes(
#     x = capacity,
#     y = speed, 
#     value = a1_perf
#   )
# )
