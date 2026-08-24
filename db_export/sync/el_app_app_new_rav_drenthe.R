source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")

db_app <- db_connect("rav_drenthe", preset = "postgres_application_admin")
db_app_new <- db_connect("rav_drenthe", preset = "postgres_application_new_admin")

table_names <- c(
  "edaz_log",
  "simulation",
  "scenario",
  "resource",
  "ambulance_task_edaz",
  "hist_account_raw",
  "hist_labourhist_attr_raw",
  "hist_labourhist_raw",
  "hist_resource_attr_raw",
  "hist_roster_raw",
  "hist_timeinterval_raw",
  "custom_hist_resourcetimestamp_raw",
  "ref_absence_raw",
  "ref_account_raw",
  "ref_attribute_raw",
  "ref_contract_raw",
  "ref_labourhist_raw",
  "ref_prop_raw",
  "ref_resource_raw",
  "ref_resourcegroup_parent_raw",
  "ref_resourcegroup_raw",
  "ref_shift_raw",
  "ref_shiftgroup_parent_raw",
  "ref_shiftgroup_raw",
  "ref_shiftpattern_raw",
  "ref_timetype_raw",
  "custom_hist_prop_raw",
  "edaz_task_raw",
  "edaz_form_raw",
  "hospital",
  "logistic",
  "personnel_contract",
  "personnel_hours",
  "psycholance",
  "psycholance_task",
  "shift",
  "station",
  "task_gms",
  "ritten_edazng_raw",
  "ritten_edazng",
  "account_names",
  "afas_raw",
  "component",
  "confused_behavior",
  "contracts",
  "edaz_valid_task",
  "function_requirements",
  "hist_dayinfo_raw",
  "hist_rosterphase_raw",
  "hist_shiftstaffing_raw",
  "hours",
  "hours_planning",
  "logistics_raw",
  "medewerkers_dashboard",
  "personnel_contract_afas",
  "personnel_in_out",
  "psycholance_task_info",
  "ref_dayinfocategory_raw",
  "ref_rosterperiod_raw",
  "ref_translations_raw",
  "resources",
  "roster_required_realisation",
  "sb_ambulance_task",
  "simulation_request",
  "vehicle",
  "verward_gedrag",
  "webfleet_tracks"
)

for(table_name in table_names) {
  message("Copy table ", table_name, " from application to application_new")
  db_app$table(table_name) |> 
    db_app_new$write(table_name, overwrite = TRUE, copy_structure = TRUE)
}

db_app$disconnect()
db_app_new$disconnect()
