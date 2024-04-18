source("Library/init.R")
prepare_gemeentescan <- import("Library/clients/jb_lorenz/mmr/prepare_gemeentescan.R")
prepare_financieel_overzicht <- import("Library/clients/jb_lorenz/mmr/prepare_financieel_overzicht.R")
database <- import("Library/database/database.R")
connections <- database$get_connections("jb_lorenz")

#dry run
gemeentescan <- prepare_gemeentescan(validation = TRUE, dry_run = TRUE)
financieel_overzicht <- prepare_financieel_overzicht(validation = TRUE, dry_run = TRUE)

#compare number of rows
connections$customer$get("SELECT COUNT(*) FROM mmr_municipalityscan_validation")
nrow(gemeentescan)

connections$customer$get("SELECT COUNT(*) FROM mmr_financial_overview_validation")
nrow(financieel_overzicht)


#if dry run tables look okay, run preparation for validation tables
gemeentescan <- prepare_gemeentescan(validation = TRUE)
financieel_overzicht <- prepare_financieel_overzicht(validation = TRUE)

#deploy for 1 municipality
#source("~/RStudio/reports/clients/jb_lorenz/mmr/dashboards/deploy_validation_scripts/hulst_deploy_validation_script.R")


#client will now check the validation dashboards, if those are okay, run preparation for regular tables
# gemeentescan <- prepare_gemeentescan(validation = FALSE)
# financieel_overzicht <- prepare_financieel_overzicht(validation = FALSE)
