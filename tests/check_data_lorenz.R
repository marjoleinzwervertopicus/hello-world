source("Library/init.R")
prepare_gemeentescan <- import("Library/clients/jb_lorenz/mmr/prepare_gemeentescan.R")
prepare_financieel_overzicht <- import("Library/clients/jb_lorenz/mmr/prepare_financieel_overzicht.R")
database <- import("Library/database/database.R")
db <- import("Library/database/db.R")
db_jb_lorenz_application <- db("jb_lorenz", host = "postgres_application_server")

#dry run
gemeentescan_new <- prepare_gemeentescan(validation = TRUE, dry_run = TRUE)
financieel_overzicht_new <- prepare_financieel_overzicht(validation = TRUE, dry_run = TRUE)

#compare number of rows
db_jb_lorenz_application$query("SELECT COUNT(*) FROM mmr_municipalityscan_validation")
gemeentescan_current <- db_jb_lorenz_application$query("SELECT * FROM mmr_municipalityscan_validation")

nrow(gemeentescan_new)

db_jb_lorenz_application$query("SELECT COUNT(*) FROM mmr_financial_overview_validation")
financieel_overzicht_current <- db_jb_lorenz_application$query("SELECT * FROM mmr_financial_overview_validation")

nrow(financieel_overzicht_new)



#client dbs
db_jb_lorenz <- db("jb_lorenz", 
                   host = "postgres_etl_server")

dim_rapporten_bridge <- db_jb_lorenz$connection$get('SELECT * FROM "DIM_RAPPORTEN_BRIDGE"')
dim_indicatoren <- db_jb_lorenz$connection$get('SELECT * FROM "DIM_INDICATOREN_LOKAAL"')
fact_kpi <-  db_jb_lorenz$connection$get('SELECT * FROM "FACT_KPI"')
dim_perioded_cbs <- db_jb_lorenz$connection$get('SELECT * FROM "DIM_PERIODEN_CBS"')
dim_regios_by_cbs <- db_jb_lorenz$connection$get('SELECT * FROM "DIM_REGIOS_PY_CBS"')


compare_datasets <- source("Library/calculate/analyse/compare_datasets.R")$value

#data for 2023 hulst but not Ommen
compare_datasets(
  financieel_overzicht_current |> group_by(year, region_name) |> summarize(n = n()),
  financieel_overzicht_new |> group_by(year, region_name) |> summarize(n = n()),
  key = c("year", "region_name")
) |> View()

dim_regios_by_cbs |> group_by(JAAR, REGIO_NAAM) |> summarize(n = n()) |> View()

#Gemeente key ommen: "GM0175"
ommen_gemeente_key <- "GM0175"

dim_regios_by_cbs |> filter(GEMEENTE_KEY == ommen_gemeente_key)


