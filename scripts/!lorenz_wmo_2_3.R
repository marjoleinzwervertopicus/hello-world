source("Library/rmd/init_dashboard.R")
db <- import("Library/database/db.R")

data <- 
  data_sources$connect(
    paste0(
      "db jb_lorenz mmr_financial_overview_validation")
  )

jb_config <- list(municipality = "Ommen")

jb_config$municipality_key <- unique(data$select(filters = list(region_name = jb_config$municipality, region_type = "GM"), calculate_column = "region_key")$region_key)

calculate <- import("Library/clients/jb_lorenz/mmr/calculate_db.R")

result_graph_clienten_duizend <-
  calculate$select_indicator_finance(data = data,
                                     theme = "WMO",
                                     indicator = "wmo_clienten_totaal",
                                     value_type = "per duizend", 
                                     municipality_key = jb_config$municipality_key,
                                     region_type = "GM", 
                                     filter_max_year = F)


result_graph_clienten_duizend %>% 
  select(x = year,
         y) %>% 
  mutate(y = round(y)) %>% 
  arrange(x) 



#render
source("Library/init.R")
reports <- import("Library/utilities/reports.R")

reports$render(paste0("clients/jb_lorenz/mmr/dashboards/financieel_overzicht/wmo/dashboard.Rmd"),
               params = list(
                 municipality = "Ommen",
                 validation = TRUE),
               runtime = "shiny_prerendered",open = T
)

reports$render(paste0("clients/jb_lorenz/mmr/dashboards/financieel_overzicht/pgb/dashboard.Rmd"),
               params = list(
                 municipality = "Ommen",
                 validation = TRUE),
               runtime = "shiny_prerendered",open = T
)




#error

connections$customer$get("SELECT indicator, value_type, region_name FROM mmr_financial_overview_validation WHERE ( ( ( (indicator IN ('pgb_kosten_wmohh') )) and municipality_key IN ('GM0175') ) and region_type IN ('GM') )")
connections$customer$get("SELECT indicator, value_type, region_name FROM mmr_financial_overview_validation WHERE ( ( ( (indicator IN ('pgb_kosten_wmohh') ))) and region_type IN ('GM') )")

db_jb_lorenz <- db("jb_lorenz", 
                   host = "postgres_etl_server")
indicatoren <- db_jb_lorenz$query('SELECT distict(INDICATOR) FROM "DIM_INDICATOREN_LOKAAL"')


#pgb error
source("Library/rmd/init_dashboard.R")

data <- 
  data_sources$connect(
    paste0(
      "db jb_lorenz mmr_financial_overview_validation")
  )

calculate <- import("Library/clients/jb_lorenz/mmr/calculate_db.R")

a <- calculate$select_indicator_finance(data = data,
                                   theme = "PGB",
                                   indicator = "pgb_clienten_wmohh",
                                   value_type = "bedrag",
                                   municipality_key = "GM0175",
                                   region_type = "GM",
                                   filter_max_year = F)


a |>
  select(region_name, indicator, y_formatted) %>%
  pivot_wider(names_from = "indicator", values_from = "y_formatted") %>%
  arrange(region_name) %>%
  select(`MMR wijk` = region_name,
         `Cliënten totaal` = pgb_clienten_wmohh,
         `Kosten totaal` = pgb_kosten_wmohh,
         `Kosten per cliënt` = pgb_kosten_per_client_wmohh)

calculate$select_indicator_finance(data = data,
                                   theme = "Jeugdhulp",
                                   indicator = "jeugd_clienten_totaal",
                                   value_type = "aantal", 
                                   municipality_key = jb_config$municipality_key,
                                   region_type = "GM", 
                                   filter_max_year = F)

a <- connections$customer$get("SELECT * FROM mmr_financial_overview_validation WHERE ( ( municipality_key IN ('GM0175') ) and region_type IN ('GM'))")
b <- connections$customer$get("SELECT indicator, value_type, region_name, year FROM mmr_municipalityscan_validation WHERE ( ( municipality_key IN ('GM0175') ) and region_type IN ('GM') )")



#----------------------
db_jb_lorenz <- db("jb_lorenz", host = "postgres_etl_server")

fact_kpi <- db_jb_lorenz$connection$get('SELECT * FROM "FACT_KPI"')
dim_indicatoren <- db_jb_lorenz$connection$get('SELECT * FROM "DIM_INDICATOREN_LOKAAL"') |> View()
db_jb_lorenz$connection$get('SELECT MIN("DIM_INDICATOREN_KEY") FROM "DIM_INDICATOREN"')
db_jb_lorenz$connection$get('SELECT MIN("DIM_INDICATOREN_KEY") FROM "DIM_INDICATOREN_LOKAAL"')

good_rows <- fact_kpi |> filter(DIM_INDICATOREN_KEY > 41, DIM_INDICATOREN_KEY < 45, DIM_PERIODEN_CBS_KEY == 57, GEMEENTE_IMPORT_FILTER == "GM0175", REGIO_IMPORT_FILTER == "GM")

db_jb_lorenz$connection$get("SELECT dim_indicatoren_key, indicator, indicator_text, theme, region_type, value_type, region_name, region_key, municipality_key, value, value_pt, value_pc, year,
semester, year_type FROM mmr_financial_overview_validation WHERE ( ( ( ( theme IN ('Jeugdhulp') and indicator IN ('jeugd_clienten_totaal') ) and value_type IN ('aantal') ) and municipality_key
IN ('GM0175') ) and region_type IN ('GM') )")

financieel_overzicht_test |> filter(theme == "Jeugdhulp", indicator == "jeugd_clienten_totaal", value_type == "aantal", municipality_key == jb_config$municipality_key, region_type == "GM") |> pull(year)

#indicatoren 2023
financieel_overzicht_test |> filter(dim_indicatoren_key %in% 41:45) |> filter(region_name == "Ommen", region_type == "GM") |> pull(indicator) |> unique()


financieel_overzicht_test |> filter(indicator %in% c("Jeugdzorgclienten totaal"), municipality_key == jb_config$municipality_key) |> pull(year) |> unique()

