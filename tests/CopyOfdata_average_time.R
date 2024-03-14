# library(profvis)
# profvis({
# Rprof()

# system.time({
params <- list(provider_name = "Groningen")

setwd(rprojroot::find_rstudio_root_file())
source("Library/rmd/init_dashboard.R") 
data <- data_sources$connect("db mknn dispatch_task_gms")
valuebox <- import("Library/visualize/widgets/valuebox.R")
graph_valuebox <- import("Library/visualize/widgets/graph_valuebox.R")
donut_valuebox <- import("Library/visualize/widgets/donut_valuebox.R")
datatable_widget <- import("Library/visualize/widgets/datatable.R")
date_utilities <- import("Library/utilities/dates.R")
time <- import("Library/utilities/time.R")
date_modal <- import("Library/tools/drilldown/date.R")

# table time formatter
# format_time_dt <- function(result, time_column, limit, urgency_column = "urgency_dispatcher") {
#   case_when(
#     result[[urgency_column]] == "A1" & result[[time_column]] > limit ~ 
#       paste0("<span style='color: ", colors("red"), "'>", time$convert_to_time(result[[time_column]]), "</span>"),
#     result[[urgency_column]] == "A1" & result[[time_column]] <= limit ~ 
#       paste0("<span style='color: ", colors("green"), "'>", time$convert_to_time(result[[time_column]]), "</span>"),
#     TRUE ~ 
#       paste0("<span style='color: ", colors("black"), "'>", time$convert_to_time(result[[time_column]]), "</span>"),
#   )
# }
# 
# skew_colors <-  function(y) {
#   if(median(y) < min(y, na.rm = TRUE) + 0.33 * (max(y, na.rm = TRUE) - min(y, na.rm = TRUE))) {
#     skew <- 2.5
#   } else if(median(y) > min(y, na.rm = TRUE) + 0.67 * (max(y, na.rm = TRUE) - min(y, na.rm = TRUE))) {
#     skew <- 0.25
#   } else {
#     skew <- 1
#   }
# }
# 
# approval_reasons <- c(
#   "Ambulance niet inzetbaar",
#   "Brandweer melding",
#   "Geen ambu beschikbaar op standplaats",
#   "Geen ambu beschikbaar in hele regio",
#   "Gegeven aan andere MKA",
#   "HAP melding",
#   "Huisartsen melding",
#   "Inzet vanuit andere regio",
#   "Koerswijziging",
#   "Lange triage",
#   "Locatie onduidelijk",
#   "Loopafstand naar ambulance",
#   "Meerdere spoedmeldingen",
#   "Meerinzet",
#   "Overdracht vorige patient",
#   "Politie melding",
#   "Taalbarriere",
#   "Vervallen",
#   "Wijziging urgentie",
#   "Andere reden"
# )
# 
if(!is.na(params$provider_name)) {
  filter_rav <-
    list(provider_name = params$provider_name)
} else {
  filter_rav <-
    list(provider_name = data$count(groups = "provider_name")$provider_name)
}
# 
daterange_select <- list(values = date_utilities$get_last_quarter())
input <- list(rb_date_a1_call_part_1_duration_trendline = "quarterly", rb_date_a1_call_part_2_duration_trendline = "quarterly",
              rb_date_a1_call_duration_trendline = "quarterly",
              rb_graph_call_approval_trend = "quarterly",
              rb_graph_dispatch_approval_trend = "quarterly")


# result <-
#   data$count(date_filter = daterange_select$values,
#              filters = filter_rav,
#              time_column = "receive_task",
#              groups = "urgency",
#              exclude_excluded = TRUE)



system.time({
  result <- 
    data$average(calculate_column = "call_part_1_duration",
                 date_filter = daterange_select$values,
                 time_column = "receive_task",
                 filters = c(
                   list(urgency_dispatcher = "A1"), 
                   filter_rav),
                 exclude_excluded = TRUE)$y
})