source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")

db_app <- db_connect("rav_gelderland_zuid", preset = "postgres_application_admin")
db_app_new <- db_connect("rav_gelderland_zuid", preset = "postgres_application_new_admin")

table_names <- c(
  "account_names",
  "contracts",
  "function_requirements",
  "hours",
  "hours_planning",
  "hr_resources",
  "prepared_contracts",
  "prepared_hours",
  "raw_hist_account",
  "raw_hist_dayinfo",
  "raw_hist_labourhist",
  "raw_hist_labourhist_attr",
  "raw_hist_resource_attr",
  "raw_hist_roster",
  "raw_hist_rosterphase",
  "raw_hist_shiftstaffing",
  "raw_hist_timeinterval",
  "raw_ref_absence",
  "raw_ref_account",
  "raw_ref_attribute",
  "raw_ref_contract",
  "raw_ref_dayinfocategory",
  "raw_ref_labourhist",
  "raw_ref_prop",
  "raw_ref_resource",
  "raw_ref_resourcegroup",
  "raw_ref_resourcegroup_parent",
  "raw_ref_rosterperiod",
  "raw_ref_shift",
  "raw_ref_shiftgroup",
  "raw_ref_shiftgroup_parent",
  "raw_ref_shiftpattern",
  "raw_ref_timetype",
  "raw_ref_translations",
  "resource",
  "resources",
  "roster_realisation",
  "roster_required_realisation",
  "sb_ambulance_task",
  "scenario",
  "trainees"
)

for(table_name in table_names) {
  message("Copy table ", table_name, " from application to application_new")
  db_app$table(table_name) |> 
    db_app_new$write(table_name, overwrite = TRUE, copy_structure = TRUE)
}

db_app$disconnect()
db_app_new$disconnect()
