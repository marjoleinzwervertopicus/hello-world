source("Library/init.R")
visualize <- import("Library/visualize/visualize.R")$create()
color_pal <- import("Library/visualize/color_pal.R")()
source("Library/rmd/init_dashboard.R") 

data <- data_sources$connect("db mknn dispatch_task_gms")

result <- data$count(groups = "incident_municipality",
                     time_column = "receive_task",
                     filters = c(
                       list(urgency = "A1")
                       ),
                     date_filter =  c(Sys.Date() %m-% days(1), Sys.Date()),
                     exclude_excluded = TRUE)

result <- result |> filter(y %in% c(4, 5))
result2 <- result
result2$fill <- pallette(result$y)


pallette <- colorNumeric(c("#B8C146", "#B0732F"), domain = 1:10)
                         
previewColors(colorNumeric(c("#B8C146", "#B0732F"), domain = 1:10), 10)


result %>%
  visualize$map(dynamic = T,
                colors = c("#B8C146", "#B0732F", "grey10"),
                theme =  list(sf = list(tooltip = list(size = 3, alpha = 0.8), alpha = 0.7)),
                labels = list(title = "Aantal A1-inzetten",
                              subtitle = paste0("In de periode: "),
                              color = "Aantal <br> A1-inzetten"),
                zoom_bounds = list(min_zoom = 7, max_zoom = 14))


result2  |>
  visualize$map(dynamic = T,
                # colors = c("#B8C146", "#B0732F", "grey10"),
                # theme =  list(sf = list(tooltip = list(size = 3, alpha = 0.8), alpha = 0.7)),
                labels = list(title = "Aantal A1-inzetten",
                              subtitle = paste0("In de periode: "),
                              color = "Aantal <br> A1-inzetten"),
                zoom_bounds = list(min_zoom = 7, max_zoom = 14))
