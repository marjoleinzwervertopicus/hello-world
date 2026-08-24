source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")

db_app <- db_connect("rav_limburg_noord", preset = "postgres_application_admin")
db_app_new <- db_connect("rav_limburg_noord", preset = "postgres_application_new_admin")

table_names <- c(
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
  "edaz_task_raw",
  "edaz_form_raw",
  "hospital",
  "logistic",
  "personnel_in_out",
  "shift",
  "station",
  "approval",
  "afas_personnel_raw",
  "burenhulp_brabant_nmw",
  "burenhulp_gelderland_zuid",
  "component",
  "dispatch_gms_edaz",
  "edaz_drfformdata_raw",
  "edaz_drfrit_raw",
  "logistics_raw",
  "personnel_contract",
  "personnel_hours",
  "ritten_edazng",
  "ritten_edazng_raw",
  "simulation_request",
  "vehicle"
)

for(table_name in table_names) {
  message("Copy table ", table_name, " from application to application_new")
  db_app$table(table_name) |> 
    db_app_new$write(table_name, overwrite = TRUE, copy_structure = TRUE)
}

db_app$disconnect()
db_app_new$disconnect()
