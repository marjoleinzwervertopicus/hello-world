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
format_time_dt <- function(result, time_column, limit, urgency_column = "urgency_dispatcher") {
  case_when(
    result[[urgency_column]] == "A1" & result[[time_column]] > limit ~ 
      paste0("<span style='color: ", colors("red"), "'>", time$convert_to_time(result[[time_column]]), "</span>"),
    result[[urgency_column]] == "A1" & result[[time_column]] <= limit ~ 
      paste0("<span style='color: ", colors("green"), "'>", time$convert_to_time(result[[time_column]]), "</span>"),
    TRUE ~ 
      paste0("<span style='color: ", colors("black"), "'>", time$convert_to_time(result[[time_column]]), "</span>"),
  )
}

skew_colors <-  function(y) {
  if(median(y) < min(y, na.rm = TRUE) + 0.33 * (max(y, na.rm = TRUE) - min(y, na.rm = TRUE))) {
    skew <- 2.5
  } else if(median(y) > min(y, na.rm = TRUE) + 0.67 * (max(y, na.rm = TRUE) - min(y, na.rm = TRUE))) {
    skew <- 0.25
  } else {
    skew <- 1
  }
}

approval_reasons <- c(
  "Ambulance niet inzetbaar",
  "Brandweer melding",
  "Geen ambu beschikbaar op standplaats",
  "Geen ambu beschikbaar in hele regio",
  "Gegeven aan andere MKA",
  "HAP melding",
  "Huisartsen melding",
  "Inzet vanuit andere regio",
  "Koerswijziging",
  "Lange triage",
  "Locatie onduidelijk",
  "Loopafstand naar ambulance",
  "Meerdere spoedmeldingen",
  "Meerinzet",
  "Overdracht vorige patient",
  "Politie melding",
  "Taalbarriere",
  "Vervallen",
  "Wijziging urgentie",
  "Andere reden"
)

if(!is.na(params$provider_name)) {
  filter_rav <- 
    list(provider_name = params$provider_name)
} else {
  filter_rav <- 
    list(provider_name = data$count(groups = "provider_name")$provider_name) 
}

daterange_select <- list(values = date_utilities$get_last_quarter())
input <- list(rb_date_a1_call_part_1_duration_trendline = "quarterly", rb_date_a1_call_part_2_duration_trendline = "quarterly",
              rb_date_a1_call_duration_trendline = "quarterly",
              rb_graph_call_approval_trend = "quarterly",
              rb_graph_dispatch_approval_trend = "quarterly")

# output$valuebox_tasks <-
#   renderUI({
    result <- 
      data$count(date_filter = daterange_select$values,
                 filters = filter_rav,
                 time_column = "receive_task",
                 groups = "urgency", 
                 exclude_excluded = TRUE)
    
    if(nrow(result) > 0){
      values <- result %>% select(name = urgency, y)
    } else {
      values <- tibble(
        name = c("A1", "A2", "B"),
        y = c(0, 0, 0)
      )
    }
    
    donut_valuebox(title = "Aantal inzetten",
                   value = values)
  # })

# output$valuebox_a1_call_duration_part_1 <-
#   renderUI({
    
    
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
    
    hidden_values <- reactive({
      data$average(calculate_column = "call_part_1_duration",
                   date_filter = c(Sys.Date() %m-% months(3), Sys.Date()),
                   time_column = "receive_task",
                   time = "weekly",
                   filters = c(
                     list(urgency_dispatcher = "A1"), 
                     filter_rav),
                   exclude_excluded = TRUE)
    })
    
    subtitle <- 
      data$percentage_target(calculate_column = "call_part_1_duration",
                             date_filter = daterange_select$values,
                             filters = c(
                               list(urgency_dispatcher = "A1"),
                               filter_rav),
                             target = list(values = 80, operation = "<="),
                             exclude_excluded = TRUE)$y
    subtitle <- paste0("Binnen norm: ", percent(subtitle))
    
    # graph_valuebox(output = output, 
    #                title = "A1-aannametijd",
    #                value = time$convert_to_time(result),
    #                icon = "fas fa-clock",
    #                icon_color = colors("blue"),
    #                subtitle = subtitle,
    #                hidden_values = hidden_values,
    #                hidden_values_compare = NULL)
  # })

# output$valuebox_a1_call_duration_part_2 <-
#   renderUI({
    result <- 
      data$average(calculate_column = "call_part_2_duration",
                   date_filter = daterange_select$values,
                   time_column = "receive_task",
                   filters = c(
                     list(urgency_dispatcher = "A1"), 
                     filter_rav),
                   exclude_excluded = TRUE)$y
    
    hidden_values <- reactive({
      data$average(calculate_column = "call_part_2_duration",
                   date_filter = c(Sys.Date() %m-% months(3), Sys.Date()),
                   time_column = "receive_task",
                   time = "weekly",
                   filters = c(
                     list(urgency_dispatcher = "A1"), 
                     filter_rav),
                   exclude_excluded = TRUE)
    })
    
    subtitle <- 
      data$percentage_target(calculate_column = "call_part_2_duration",
                             date_filter = daterange_select$values,
                             filters = c(
                               list(urgency_dispatcher = "A1"),
                               filter_rav),
                             target = list(values = 40, operation = "<="),
                             exclude_excluded = T)$y
    subtitle <- paste0("Binnen norm: ", percent(subtitle))
    
    # graph_valuebox(output = output, 
    #                title = "A1-uitgiftetijd",
    #                value = time$convert_to_time(result),
    #                icon = "fas fa-clock",
    #                icon_color = colors("purple"),
    #                subtitle = subtitle,
    #                hidden_values = hidden_values,
    #                hidden_values_compare = NULL)
  # })

# output$valuebox_a1_call_duration <-
#   renderUI({
    
    result <- 
      data$average(calculate_column = "call_duration",
                   date_filter = daterange_select$values,
                   time_column = "receive_task",
                   filters = c(
                     list(urgency_dispatcher = "A1",
                          call_duration_outlier = FALSE), 
                     filter_rav),
                   exclude_excluded = TRUE)$y
    
    hidden_values <- reactive({
      data$average(calculate_column = "call_duration",
                   date_filter = c(Sys.Date() %m-% months(3), Sys.Date()),
                   time_column = "receive_task",
                   time = "weekly",
                   filters = c(
                     list(urgency_dispatcher = "A1",
                          call_duration_outlier = FALSE), 
                     filter_rav),
                   exclude_excluded = TRUE)
    })
    
    subtitle <- 
      data$percentage_target(calculate_column = "call_duration",
                             filters = filter_rav,
                             date_filter = daterange_select$values,
                             target = list(values = 2*60, operation = "<="),
                             exclude_outliers = TRUE,
                             exclude_excluded = TRUE)$y
    subtitle <- paste0("Binnen norm: ", percent(subtitle))
    
    # graph_valuebox(output = output, 
    #                title = "A1-meldtijd",
    #                value = time$convert_to_time(result),
    #                icon = "fas fa-clock",
    #                icon_color = colors("green"),
    #                subtitle = subtitle,
    #                hidden_values = hidden_values,
    #                hidden_values_compare = NULL)
  # })

    call_part_1_duration <- 
      left_join(
        data$average(calculate_column = "call_part_1_duration",
                     groups = c("first_call_centralist_code"),
                     date_filter = daterange_select$values,
                     time_column = "receive_task",
                     filters = c(
                       list(urgency = "A1"),
                       filter_rav),
                     exclude_excluded = T) %>%
          arrange(desc(y)) %>%
          filter(!is.na(first_call_centralist_code)) %>%
          select(centralist_code = first_call_centralist_code,
                 call_part_1_duration = y),
        
        data$percentage_target(calculate_column = "call_part_1_duration",
                               groups = c("first_call_centralist_code"),
                               date_filter = daterange_select$values,
                               filters = c(
                                 list(urgency_dispatcher = "A1"),
                                 filter_rav),
                               target = list(values = 80, operation = "<="),
                               exclude_excluded = T) %>%
          mutate(y = percent(y)) %>%
          select(centralist_code = first_call_centralist_code, 
                 call_part_1_duration_within_target = y) 
      )
    
    call_part_2_duration <- 
      left_join(
        data$average(calculate_column = "call_part_2_duration",
                     groups = c("deployment_centralist_code"),
                     date_filter = daterange_select$values,
                     time_column = "receive_task",
                     filters = c(
                       list(urgency = "A1"),
                       filter_rav),
                     exclude_excluded = T) %>%
          arrange(desc(y)) %>%
          filter(!is.na(deployment_centralist_code)) %>%
          select(centralist_code = deployment_centralist_code,
                 call_part_2_duration = y),
        
        data$percentage_target(calculate_column = "call_part_2_duration",
                               groups = c("deployment_centralist_code"),
                               date_filter = daterange_select$values,
                               filters = c(
                                 list(urgency_dispatcher = "A1"),
                                 filter_rav),
                               target = list(values = 40, operation = "<="),
                               exclude_excluded = T) %>%
          mutate(y = percent(y)) %>%
          select(centralist_code = deployment_centralist_code, 
                 call_part_2_duration_within_target = y)
      )
    
    
    result <- left_join(call_part_1_duration, call_part_2_duration, by = c("centralist_code"))
    result$call_part_1_duration <- time$convert_to_time(result$call_part_1_duration)
    result$call_part_2_duration <- time$convert_to_time(result$call_part_2_duration)
    
    result <- 
      result %>%
      select(centralist_code, 
             call_part_1_duration,
             call_part_1_duration_within_target,
             call_part_2_duration,
             call_part_2_duration_within_target) %>%
      arrange(centralist_code)
    result$centralist_code <- "..."
    
    visualize$table(result, 
                    table_format = "dt",
                    styles = list("call_part_1_duration_within_target" = "background_gradient",
                                  "call_part_2_duration_within_target" = "background_gradient"),
                    col_names = c("Centralist ID", 
                                  "Aannametijd", 
                                  "Aanname binnen norm (%)", 
                                  "Uitgiftetijd", 
                                  "Uitgifte binnen norm(%)"),
                    page_length = 10,
                    buttons = c("excel_icon"))
    
    
    
    
    result <-
      data$average(calculate_column = "call_part_1_duration",
                   time_column = "receive_task", 
                   time = input$rb_date_a1_call_part_1_duration_trendline,
                   filters = c(
                     list(urgency = "A1"),
                     filter_rav),
                   exclude_excluded = T)
    
    visualize$graph(result,
                    interactive = T,
                    types = list(spline = T),
                    theme = list(spline = list(marker = T)),
                    colors = colors("blue"),
                    options = list(navigator = T,
                                   export_enabled = T,
                                   tooltip_shared = T,
                                   duration = T),
                    labels = list(title = texts$add_date_zoom(text = "A1-aannametijd", 
                                                              input$rb_date_a1_call_part_1_duration_trendline),
                                  x = "",
                                  y = "Gemiddelde aannametijd"))
    
    
    
    result <-
      data$average(calculate_column = "call_part_2_duration",
                   time_column = "receive_task", 
                   time = input$rb_date_a1_call_part_2_duration_trendline,
                   filters = c(
                     list(urgency = "A1"),
                     filter_rav),
                   exclude_excluded = T) 
    
    visualize$graph(result,
                    interactive = T,
                    types = list(spline = T),
                    theme = list(spline = list(marker = T)),
                    colors = colors("purple"),
                    options = list(navigator = T,
                                   export_enabled = T,
                                   tooltip_shared = T,
                                   duration = T),
                    labels = list(title = texts$add_date_zoom(text = "A1-uitgiftetijd", 
                                                              input$rb_date_a1_call_part_2_duration_trendline),
                                  x = "",
                                  y = "Gemiddelde uitgiftetijd"))
    
    
    result <-
      data$average(calculate_column = "call_duration",
                   time_column = "receive_task", 
                   time = input$rb_date_a1_call_duration_trendline,
                   filters = c(
                     list(urgency = "A1",
                          call_duration_outlier = TRUE),
                     filter_rav),
                   exclude_excluded = T)
    
    visualize$graph(result,
                    interactive = T,
                    types = list(spline = T),
                    theme = list(spline = list(marker = T)),
                    colors = colors("green"),
                    options = list(navigator = T,
                                   export_enabled = T,
                                   tooltip_shared = T,
                                   duration = T),
                    labels = list(title = texts$add_date_zoom(text = "A1-meldtijd", 
                                                              input$rb_date_a1_call_duration_trendline),
                                  x = "",
                                  y = "Gemiddelde meldtijd"))
    
    
    result <- 
      data$count(date_filter = daterange_select$values,
                 time_column = "receive_task", 
                 groups = "call_approval",
                 filters = c(
                   list(urgency = "A1",
                        call_part_1_duration_delayed = TRUE), 
                   filter_rav),
                 exclude_excluded = TRUE) %>%
      ungroup() %>%
      mutate(x = call_approval)  %>% 
      slice_head(n = 5) %>%
      arrange(desc(y))
    
    result$x <- factor(result$x, result$x)
    
    result <-
      result %>%
      select(x, y) %>%
      arrange(x) 
    
    result[is.na(result)] <- "Onbekend"
    
    visualize$graph(result,
                    interactive = T,
                    types = list(bar = T),
                    options = list(tooltip_shared = T,
                                   export_enabled = T,
                                   label = T,
                                   rotate = T),
                    labels = list(title = "Top 5 motivaties A1-aannameoverschrijding",
                                  subtitle = paste0("In de periode: ", date_utilities$daterange_to_text(daterange_select$values)),
                                  y = "Aantal",
                                  x = "",
                                  fill = ""))
    
    result <- 
      data$count(date_filter = daterange_select$values,
                 time_column = "receive_task", 
                 groups = "dispatch_approval",
                 filters = c(
                   list(urgency = "A1",
                        call_part_2_duration_delayed = TRUE),
                   filter_rav),
                 exclude_excluded = TRUE) %>%
      ungroup() %>%
      mutate(x = dispatch_approval)  %>% 
      slice_head(n = 5) %>%
      arrange(desc(y))
    
    result$x <- factor(result$x, result$x)
    
    result <-
      result %>%
      select(x, y) %>%
      arrange(x) 
    
    result[is.na(result)] <- "Onbekend"
    
    visualize$graph(result,
                    interactive = T,
                    types = list(bar = T),
                    colors = colors("purple"),
                    options = list(tooltip_shared = T,
                                   export_enabled = T,
                                   label = T,
                                   rotate = T),
                    labels = list(title = "Top 5 motivaties A1-uitgifteoverschrijding",
                                  subtitle = paste0("In de periode: ", date_utilities$daterange_to_text(daterange_select$values)),
                                  y = "Aantal",
                                  x = "",
                                  fill = ""))
    
    
    result <- 
      data$count(date_filter = daterange_select$values,
                 time_column = "receive_task", 
                 groups = "call_approval",
                 filters = c(
                   list(urgency = "A1",
                        call_part_1_duration_delayed = TRUE), 
                   filter_rav),
                 exclude_excluded = TRUE) %>%
      ungroup() %>%
      rename(x = call_approval) %>%
      arrange(desc(y))
    result[is.na(result)] <- "Onbekend"
    
    visualize$graph(result,
                    interactive = T,
                    types = list(bar = T),
                    options = list(tooltip_shared = T,
                                   export_enabled = T,
                                   label = T),
                    labels = list(title = "Motivaties A1-aannameoverschrijding",
                                  subtitle = paste0("In de periode: ", date_utilities$daterange_to_text(daterange_select$values)),
                                  y = "Aantal",
                                  x = "Motivatie"))
    
    
    
    
    #
    # if(input$selectize_filter_call_approval == "Alle motivaties") {
      call_approval <- approval_reasons
    # } else {
    #   call_approval <- input$selectize_filter_call_approval
    # }
    
    result <- 
      data$count(time_column = "receive_task", 
                 time = input$rb_graph_call_approval_trend,
                 groups = "call_approval",
                 filters = c(
                   list(urgency = "A1",
                        call_part_1_duration_delayed = TRUE,
                        call_approval = call_approval), 
                   filter_rav),
                 exclude_excluded = TRUE)
    result[is.na(result)] <- "Onbekend"
    
    visualize$graph(result,
                    interactive = T,
                    types = list(spline = T),
                    options = list(tooltip_shared = T,
                                   navigator = T,
                                   export_enabled = T),
                    theme = list(spline = list(marker = T)),
                    labels = list(title = texts$add_date_zoom(text = "Motivatie A1-aannameoverschrijding", 
                                                              date_zoom = input$rb_graph_call_approval_trend),
                                  y = "Aantal",
                                  x = "",
                                  fill = "Motivatie"))
    
    
    result <-
      data$count(date_filter = daterange_select$values,
                 time_column = "receive_task",
                 groups = "dispatch_approval",
                 filters = c(
                   list(urgency = "A1",
                        call_part_2_duration_delayed = TRUE), 
                   filter_rav),
                 exclude_excluded = TRUE) %>%
      ungroup() %>%
      rename(x = dispatch_approval) %>%
      arrange(desc(y))
    result[is.na(result)] <- "Onbekend"
    
    visualize$graph(result,
                    interactive = T,
                    types = list(bar = T),
                    colors = colors("purple"),
                    options = list(tooltip_shared = T,
                                   export_enabled = T,
                                   label = T),
                    labels = list(title = "Motivaties A1-uitgifteoverschrijding",
                                  subtitle = paste0("In de periode: ", date_utilities$daterange_to_text(daterange_select$values)),
                                  y = "Aantal",
                                  x = "Motivatie"))
    
    
    # if(input$selectize_filter_dispatch_approval == "Alle motivaties") {
      dispatch_approval <- approval_reasons
    # } else {
    #   dispatch_approval <- input$selectize_filter_dispatch_approval
    # }
    
    result <- 
      data$count(time_column = "receive_task", 
                 time = input$rb_graph_dispatch_approval_trend,
                 groups = "dispatch_approval",
                 filters = c(
                   list(urgency = "A1",
                        call_part_2_duration_delayed = TRUE,
                        dispatch_approval = dispatch_approval),
                   filter_rav),
                 exclude_excluded = TRUE)
    result[is.na(result)] <- "Onbekend"
    
    visualize$graph(result,
                    interactive = T,
                    types = list(spline = T),
                    theme = list(spline = list(marker = T)),
                    options = list(tooltip_shared = T,
                                   navigator = T,
                                   export_enabled = T),
                    labels = list(title = texts$add_date_zoom(text = "Motivatie A1-uitgifteoverschrijding", 
                                                              date_zoom = input$rb_graph_dispatch_approval_trend),
                                  y = "Aantal",
                                  x = "",
                                  fill = "Motivatie"))
    
    bbox <- geography$download$rav_region(c("RAV Drenthe (3)", "RAV Friesland (2)", "RAV Groningen (1)"))
    
    result <- 
      data$count(groups = "incident_municipality",
                 time_column = "receive_task",
                 filters = c(
                   list(urgency = "A1"),
                   filter_rav),
                 date_filter =  daterange_select$values,
                 exclude_excluded = TRUE) %>%
      mutate(tooltip = paste0(tags$b(incident_municipality), "<br> Aantal inzetten: ", y)) 
    
    result %>%
      visualize$map(dynamic = T,
                    # colors = colors(c("#AAAAAA", "#4796AE", "#275461"), n = 10, skew = skew_colors(result$y), alpha = 0.6),
                    bbox = bbox,
                    theme =  list(sf = list(tooltip = list(size = 3, alpha = 0.8), alpha = 0.7)),
                    labels = list(title = "Aantal A1-inzetten",
                                  subtitle = paste0("In de periode: "),
                                  color = "Aantal <br> A1-inzetten"),
                    zoom_bounds = list(min_zoom = 7, max_zoom = 14))
    
    
    
    # urgency_filter <- input$selectize_tasks_trendline
    urgency_filter <- c("A1", "A2", "B")
    
    result <-
      data$count(time_column = "receive_task", 
                 filters = c(filter_rav,
                             list(urgency = urgency_filter)),
                 time = input$rb_date_tasks_trendline,
                 exclude_excluded = T)
    
    
    # if(input$selectize_tasks_trendline == "Alle urgenties") {
    #   result <-
    #     data$count(time_column = "receive_task", 
    #                time = input$rb_date_tasks_trendline,
    #                groups = "urgency",
    #                exclude_excluded = TRUE)
    #   types <- list(areaspline = TRUE)
    # } else {
    #   result <-
    #     data$count(time_column = "receive_task", 
    #                time = input$rb_date_tasks_trendline,
    #                filter = list(urgency = input$selectize_tasks_trendline),
    #                exclude_excluded = T)
    #   types <- list(spline = TRUE)
    # }
    
    title <- paste0("Aantal inzetten ", texts$add_date_zoom(date_zoom = "quarterly"))

    # visualize$graph(result,
    #                 interactive = T,
    #                 types = list(spline = TRUE),
    #                 theme = list(spline = list(marker = T)),
    #                 # colors = colors(c("blue", "green", "lime")),
    #                 options = list(navigator = T,
    #                                export_enabled = T,
    #                                tooltip_shared = T),
    #                 labels = list(title = title,
    #                               x = "",
    #                               y = "Aantal inzetten",
    #                               fill = "Urgentie"))
    
    
    result <- 
      data$count_json(calculate_column = "proqa",
                      date_filter = daterange_select$values,
                      time_column = "receive_task", 
                      groups = "proqa",
                      filters = c(
                        list(urgency = "A1"), 
                        filter_rav),
                      exclude_excluded = TRUE) %>%
      ungroup() %>%
      rename(x = proqa) %>%
      arrange(desc(y))
    result[is.na(result)] <- "Onbekend"
    
    visualize$graph(result,
                    interactive = T,
                    types = list(bar = T),
                    options = list(tooltip_shared = T,
                                   export_enabled = T,
                                   label = T),
                    labels = list(title = "Aantal A1-inzetten per ProQA",
                                  subtitle = paste0("In de periode: ", date_utilities$daterange_to_text(daterange_select$values)),
                                  y = "Aantal inzetten",
                                  x = "ProQA"))
    
# })
    
    # Rprof(NULL)
    # summaryRprof()


