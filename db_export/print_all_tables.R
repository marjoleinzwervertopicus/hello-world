library(db)

# tables that are unused for all clients (kept in sync with simple_dump.sh)
excluded_tables <- c(
  "dashboard", "data_statistics", "data_summary", "email_queue", "guide", "flag", "input_state", "insight",
  "message", "message_user", "metadata_calculate", "metadata_variable",
  "user_dashboard", "usergroup", "user_group", "user_group_insight", "user_guide", "user_info", "user_insight",
  "user_message", "user_metadata_calculate", "user_metadata_variable", "user_statistics", "user_user_group"
)

# per-database excludes (kept in sync with simple_dump.sh)
excluded_tables_per_db <- list(
  mmt_gr = "bag_woonplaats_mei_23",
  platform = c("bag", "customer", "driving_time", "lexicon", "shape_point"),
  rav_groningen = c("logistic", "logistic_backup"),
  rav_brabant_midden_west_noord = "raw_ortec",
  mmt_ams = "bag_woonplaats_mei_23",
  mknn = "gms_rit_raw",
  mk_limburg = c("data_statistics", "gms_task_2022_01_01_2022_01_31"),
  rav_limburg_noord = c("message_user", "ambulance_task_edaz_2022_01_01_2022_01_31", "ambulance_task_edaz_backup",
                        "ambulance_task_edaz_bk", "edaz_task_raw_backup", "logistic_backup", "logistic_temp_1",
                        "logistic_test", "personnel_contract_backup", "personnel_contract_temp",
                        "personnel_hours_backup", "personnel_hours_temp", "personnel_in_out_backup",
                        "personnel_in_out_temp", "test", "test_dropme"),
  geography = "testtest",
  rav_ijsselland = c("ambulance_task_edaz_2022_01_01_2022_01_31", "edaz_task_raw_old", "logistic_backup", "test1"),
  rav_drenthe = c("backup_afas_raw", "edaz_form_raw_2022_01_01_2022_01_31", "edaz_task_raw_2022_01_01_2022_01_31",
                 "hist_account_raw_2022_01_01_2022_01_31", "hist_roster_raw_2022_01_01_2022_01_31",
                 "hist_timeinterval_raw_2022_01_01_2022_01_31", "logistic2", "logistic2_backup", "logistic2_temp",
                 "personnel_contract_bk_2024", "personnel_contract_old", "personnel_contract_temp",
                 "personnel_in_out_backup", "personnel_in_out_temp", "psycholance_backup", "psycholance_backup_12_3",
                 "psycholance_backup_18_2", "synergy_task_inbox_backup", "test_tz"),
  rav_fryslan = c("ambulance_task_edaz_2022_01_01_2022_01_31", "ambulance_task_edaz_backup_20260422",
                 "ambulance_task_edaz_temp", "downtime2", "json_test", "logistic_backup", "qa_backup"),
  rav_utrecht = "sb_ambulance_task_2025_q4",
  roaz_aznn = c("roaz_ggz_old", "roaz_hap_old", "roaz_ketenzorg_old", "roaz_rav_old", "roaz_seh_old"),
  rav_limburg_zuid = c("ambulance_task_edaz_2022_01_01_2022_01_31", "ambulance_task_edaz_bk", "edaz_task_raw_old")
)

db_names <- c(
  "hap_hcdo",
  "kwaliteitskaderapp",
  "mmt_gr",
  "platform",
  "rav_groningen",
  "rav_brabant_midden_west_noord",
  "mmt_ams",
  "mknn",
  "rav_oost",
  "mk_limburg",
  "rav_limburg_noord",
  "geography",
  "rav_twente",
  "rav_ijsselland",
  "rav_drenthe",
  "rav_fryslan",
  "rav_brabant_zuidoost",
  "rav_gelderland_zuid",
  "rav_utrecht",
  "rav_hollands_midden",
  "lazk",
  "roaz_aznn",
  "rav_limburg_zuid"
)

for (db_name in db_names) {
  connections <- db_connect(db_name, preset = "postgres_application_admin")
  table_names <- connections$info$tables()$table_name
  table_names <- sub("^public\\.", "", table_names)

  db_excluded_tables <- c(excluded_tables, excluded_tables_per_db[[db_name]])

  # client_info is old for every client except LAZK and kwkapp (kept in sync with simple_dump.sh)
  if (!db_name %in% c("kwaliteitskaderapp", "lazk")) {
    db_excluded_tables <- c(db_excluded_tables, "client_info")
  }

  table_names <- table_names[!table_names %in% db_excluded_tables]

  cat("Database: ", db_name, "\n")
  cat(paste0(table_names, collapse = "\n"), "\n\n")

  connections$disconnect()
}
