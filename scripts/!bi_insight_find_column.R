source("Library/init.R")
files <- source("Library/utilities/files.R")$value
drilldown_state <- import("Library/tools/drilldown/drilldown_state.R")
Group <- import("Library/tools/drilldown/group_factory.R")
insight_config <- import("utilities/insight_config.R")


insight_config$get_all_insights()

check_old_reports <- function(reports) {
  count_percentage_reports <- c()
  for(row_index in 1:nrow(reports)) {
    if(reports[row_index, ]$type %in% c("Drilldown")) {
      report <- drilldown_state$unserialise(reports[row_index, ]$value)
      if("call_line" %in% report$reactives$groups$values) {
        count_percentage_reports <- c(count_percentage_reports, reports[row_index, ]$name)
      }
    }
  }
  
  count_percentage_reports
}

clients <-"rav_limburg_zuid"

fix_reports_for_clients(clients)
