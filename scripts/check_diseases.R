source("Library/init.R")
database <- import("Library/database/database.R")
drilldown_state <- import("Library/tools/drilldown/drilldown_state.R")
Group <- import("Library/tools/drilldown/group_factory.R")
Data <- import("Platform/R/platformLibrary/tools/insight_manager/data.R")


check_reports_to_edit <- function( edit = FALSE) {
  count_percentage_reports <- c()
  for(row_index in 1:nrow(reports)) {
    if(reports[row_index, ]$type %in% c("Drilldown")) {
      report <- drilldown_state$unserialise(reports[row_index, ]$value)
      
      if(report$reactives$calculate_functions$values == "count_percentage") {
        count_percentage_reports <- c(count_percentage_reports, reports[row_index, ]$name)
        
        if(edit) {
          report$reactives$calculate_functions$values <- "count"
          report$reactives$use_proportion <- list(values = TRUE)
          report$reactives$groups <- Group(report$reactives$groups)
          new_value <- drilldown_state$serialise(report$reactives, active_tab = report$active_tab)
          
          edited_insight <- tibble(insight_id = reports[row_index, ]$insight_id,
                                   old_owner = reports[row_index, ]$owner_id,
                                   name = reports[row_index, ]$name,
                                   description = reports[row_index, ]$description,
                                   date = reports[row_index, ]$date,
                                   type = reports[row_index, ]$type,
                                   value = new_value,
                                   owner_id = reports[row_index, ]$owner_id,
                                   icon = reports[row_index, ]$icon)
          data$update$insight(edited_insight)
        }
      }
      
    }
  }
  
  count_percentage_reports
}

check_old_reports <- function(reports) {
  count_percentage_reports <- c()
  for(row_index in 1:nrow(reports)) {
    if(reports[row_index, ]$type %in% c("Drilldown")) {
      report <- drilldown_state$unserialise(reports[row_index, ]$value)
      browser()
      # if(report$active_tab)
      
      
    }
  }
  
  count_percentage_reports
}

clients <- c("rav_drenthe", "rav_fryslan", "rav_limburg_noord", "rav_limburg_zuid", "rav_ijsselland", "mk_limburg")

fix_reports_for_clients(clients)
