source("Library/rmd/init_dashboard.R")  
display_messages <<- FALSE
make_gradient <- import("Library/visualize/colors/make_gradient.R")
time <- import("Library/utilities/time.R")
date_utilities <- import("Library/utilities/dates.R")

azn_filters <- source("Library/modules/ambulance_medical/kwaliteitsindicatoren_azn_dashboard/calculates/filters.R")$value 
azn_calculate <- import("Library/modules/ambulance_medical/kwaliteitsindicatoren_azn_dashboard/calculates/generate_azn_results.R")
data_export <- import("Library/modules/ambulance_medical/kwaliteitsindicatoren_azn_dashboard/calculates/data_export.R")
result_export <- import("Library/modules/ambulance_medical/kwaliteitsindicatoren_azn_dashboard/calculates/result_export.R")

create_norm_line <- function(norm, color = colors("grey")) {
  list(value = norm,
       color = color,
       dashStyle = "LongDash",
       width = 1,
       zIndex = 4)
}
min_date <- as.Date(paste0(year(Sys.Date()) - 3, "-01-01"))
max_date_monthly <- floor_date(Sys.Date(), unit = "month") - days(1)
max_date_quarterly <- floor_date(Sys.Date(), unit = "quarter") - days(1)
min_date_overview <- floor_date(max_date_monthly - years(1), unit = "month")

date_filter_overview <- as.Date(c(min_date_overview, max_date_monthly))
date_filter_monthly <- as.Date(c(min_date, max_date_monthly))
date_filter_quarterly <- as.Date(c(min_date, max_date_quarterly))

azn_norms <- list(
  cva = 0.8 * 100,
  stemi_45 = 0.56 * 100,
  stemi_60 = 0.9 * 100,
  opnieuw_ambu_24 = 0.023 * 100, 
  opnieuw_ambu_72 = 0.036 * 100,
  pijn_registratie = 0.59 * 100,
  pijn_behandeling = 0.94 * 100
)

params <- list(client = "rav_drenthe")

config <- 
  list(client = params$client)
if(config$client == "rav_drenthe") {
  client_name <- "UMCG Ambulancezorg"
} else if(config$client == "rav_fryslan") {
  client_name <- "RAV Fryslân"
} else if(config$client == "rav_limburg_noord") {
  client_name <- "AmbulanceZorg Limburg-Noord"
}

data <- data_sources$connect(paste0("db ", config$client, " ambulance_task_edaz"))
connection <- database$get_connections(config$client, persistent = FALSE)
calculate_db <- import("Library/modules/ambulance_medical/kwaliteitsindicatoren_azn_dashboard/calculates/azn_calculates.R")
calculate_db <- calculate_db$create(connection = connection[[config$client]],
                                    table_name = "ambulance_task_edaz",
                                    time_column = "receive_task")
change_dashboard_options(daterange_select = date_utilities$get_last_quarter())
station_names <-
  data$count(groups = "station_name", 
             exclude_excluded = T, 
             date_filter = c("2018-01-01", as.character(max_date_monthly)))$station_name
duration_names <-
  list("Meldtijdsduur" = "call",
       "Uitruktijdsduur" = "preparation",
       "Aanrijtijdsduur" = "move_to_incident",
       "Responstijdsduur" = "response",
       "Behandeltijdsduur" = "treatment",
       "Transporttijdsduur" = "move_to_destination",
       "Melding tot bestemming tijdsduur" = "call_to_destination",
       "Overdrachttijdsduur" = "transfer",
       "Naar standplaats tijdsduur" = "move_to_station",
       "Ambulance bezet tijdsduur" = "busy",
       "Incidenttijdsduur" = "incident",
       "Inzettijdsduur" = "task")



#------------------------------------------------------------------------data---------------------------------------------------------------------
display_messages <<- FALSE
#TAB1: Maand ----
graph_opnieuw_ambulancezorg_monthly <-
  azn_calculate$count_opnieuw_ambulancezorg(data = data,
                                            azn_filters = azn_filters,
                                            time = "monthly",
                                            date_filter = date_filter_monthly) %>%
  visualize$graph(interactive = T,
                  options = list(percent = T,
                                 export_enabled = T,
                                 navigator = T),
                  types = list(areaspline = T),
                  labels = list(title = "Percentage opnieuw ambulancezorg binnen 24 en 72 uur per maand",
                                subtitle = paste0("Streefwaarde maximaal binnen 24 uur ", azn_norms$opnieuw_ambu_24, "% en binnen 72 uur ", azn_norms$opnieuw_ambu_72, "%"),
                                x = "",
                                y = "Percentage opnieuw ambu. binnen 24 en 72 uur",
                                fill = "Norm"))


graph_opnieuw_ambulancezorg_monthly$x$hc_opts$yAxis$plotLines <-
  list(create_norm_line(azn_norms$opnieuw_ambu_24),
       create_norm_line(azn_norms$opnieuw_ambu_72))


#TAB 2: Kwartaal  ----
graph_opnieuw_ambulancezorg_quarterly <-
  azn_calculate$count_opnieuw_ambulancezorg(data = data,
                                            azn_filters = azn_filters,
                                            time = "quarterly",
                                            date_filter = date_filter_quarterly) %>%
  visualize$graph(interactive = T,
                  options = list(percent = T,
                                 export_enabled = T,
                                 navigator = T),
                  types = list(areaspline = T),
                  labels = list(title = "Percentage opnieuw ambulancezorg binnen 24 en 72 uur per kwartaal",
                                subtitle = paste0("Streefwaarde maximaal binnen 24 uur ", azn_norms$opnieuw_ambu_24, "% en binnen 72 uur ", azn_norms$opnieuw_ambu_72, "%"),
                                x = "",
                                y = "Percentage opnieuw ambu. binnen 24 en 72 uur",
                                fill = "Norm"))
graph_opnieuw_ambulancezorg_quarterly$x$hc_opts$yAxis$plotLines <-
  list(create_norm_line(azn_norms$opnieuw_ambu_24),
       create_norm_line(azn_norms$opnieuw_ambu_72))

#TAB1: Maand ----
table_opnieuw_ambulancezorg_monthly <-
  azn_calculate$count_opnieuw_ambulancezorg(data = data,
                                            azn_filters = azn_filters,
                                            time = "monthly",
                                            date_filter = date_filter_monthly) %>%
  pivot_wider(names_from = "group", values_from = "y") %>%
  rename(per_24 = `Binnen 24 uur`,
         per_72 = `Binnen 72 uur`) %>%
  arrange(desc(x)) %>%
  mutate(x = format(x, "%b %Y"),
         per_24 = kableExtra::cell_spec(per_24,
                                        color = "white",
                                        background = make_gradient(per_24,
                                                                   colors = colors(3))),
         per_72 = kableExtra::cell_spec(per_72,
                                        color = "white",
                                        background = make_gradient(per_72,
                                                                   colors = colors(3)))) %>%
  select(Maand = x,
         `Opnieuw ambu. binnen 24 uur` = per_24,
         `Opnieuw ambu. binnen 72 uur` = per_72,
         `Totaal EHTP` = total) %>%
  visualize$table(table_format = "dt",
                  fill_container = T,
                  page_length = 9)

#TAB1: Kwartaal ----
table_opnieuw_ambulancezorg_quarterly <-
  azn_calculate$count_opnieuw_ambulancezorg(data = data,
                                            azn_filters = azn_filters,
                                            time = "quarterly",
                                            date_filter = date_filter_quarterly) %>%
  pivot_wider(names_from = "group", values_from = "y") %>%
  rename(per_24 = `Binnen 24 uur`,
         per_72 = `Binnen 72 uur`) %>%
  arrange(desc(x)) %>%
  mutate(x = paste0(quarters(x), " ", year(x)),
         per_24 = kableExtra::cell_spec(per_24,
                                        color = "white",
                                        background = make_gradient(per_24,
                                                                   colors = colors(3))),
         per_72 = kableExtra::cell_spec(per_72,
                                        color = "white",
                                        background = make_gradient(per_72,
                                                                   colors = colors(3)))) %>%
  select(Kwartaal = x,
         `Opnieuw ambu. binnen 24 uur` = per_24,
         `Opnieuw ambu. binnen 72 uur` = per_72,
         `Totaal EHTP` = total) %>%
  visualize$table(table_format = "dt",
                  fill_container = T,
                  page_length = 9)