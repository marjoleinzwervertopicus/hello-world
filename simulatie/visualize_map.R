source("Library/init.R")
library(highcharter)
library(leaflet)
visualize <- import("Library/visualize/visualize.R")$create()
files <- import("Library/utilities/files.R")

# file_path <- "~/RStudio/hello_world/!simulatie/scenario_3_cap_120_snel_83_tasks.csv"

file_path_elec <- "~/RStudio/hello_world/!simulatie/scenario_3_cap_60_snel_60_tasks.csv"
file_path_reg <- "~/RStudio/hello_world/!simulatie/scenario_1_default_geen_elektrisch_tasks.csv"

tasks_reg <- files$load_file(file_path_reg)
tasks_elec <- files$load_file(file_path_elec)

tasks_reg <- tasks_reg %>% select(incident_latitude, incident_longitude, change_delayed)
tasks_reg <- tasks_reg %>% mutate(across(everything(), as.numeric))

tasks_elec <- tasks_elec %>% select(incident_latitude, incident_longitude, change_delayed)
tasks_elec <- tasks_elec %>% mutate(across(everything(), as.numeric))

is_chance_different <- tasks_reg$incident_latitude == tasks_elec$incident_latitude & tasks_reg$incident_longitude == tasks_elec$incident_longitude & tasks_reg$change_delayed != tasks_elec$change_delayed 
can_compare <- tasks_reg$incident_latitude == tasks_elec$incident_latitude & tasks_reg$incident_longitude == tasks_elec$incident_longitude



mean_diff_chance_delayed <- (mean(tasks_reg$change_delayed[can_compare]) - mean(tasks_elec$change_delayed[can_compare])) * 100

task_diff <- tasks_reg
task_diff$change_delayed <- (task_diff$change_delayed - tasks_elec$change_delayed) * 100


tasks_reg <- tasks_reg[is_chance_different, ]
tasks_elec <- tasks_elec[is_chance_different, ]




color_ramp <- colorRamp(c("red", "orange", "green"))
# color_func <- function(x) do.call(rgb, as.list(color_ramp(x)/255))
color_numeric <- colorNumeric(color_ramp, unique(task_diff$change_delayed))
task_diff$color <- map_chr(task_diff$change_delayed, ~color_numeric(.))

theme <- list(
  point = list(size = 2, alpha = 0.8)
)
              
map <- visualize$map(task_diff, dynamic = T, theme = theme)
map %>% addLegend(pal = color_numeric, values = unique(task_diff$change_delayed),
                  title = "verschil in kans op vertraging", labFormat = labelFormat(suffix = "%-punt"))
