source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")

db_app <- db_connect("rav_ijsselland", preset = "postgres_application_admin")
db_app_new <- db_connect("rav_ijsselland", preset = "postgres_application_new_admin")

table_names <- c(
  "simulation",
  "scenario",
  "resource",
  "edaz_task_raw",
  "edaz_form_raw",
  "ambulance_task_edaz",
  "hist_account_raw",
  "hist_labourhist_raw",
  "hist_roster_raw",
  "hist_resource_attr_raw",
  "hist_labourhist_attr_raw",
  "hist_timeinterval_raw",
  "custom_hist_prop_raw",
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
  "personnel_hours",
  "personnel_contract",
  "edaz_valid_task",
  "hist_dayinfo_raw",
  "hist_rosterphase_raw",
  "hist_shiftstaffing_raw",
  "logistic",
  "ref_dayinfocategory_raw",
  "ref_rosterperiod_raw",
  "ref_translations_raw",
  "sb_ambulance_task"
)

for(table_name in table_names) {
  message("Copy table ", table_name, " from application to application_new")
  db_app$table(table_name) |> 
    db_app_new$write(table_name, overwrite = TRUE, copy_structure = TRUE)
}

db_app$disconnect()
db_app_new$disconnect()
