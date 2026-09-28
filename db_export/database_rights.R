library(db)

querytool_users <- c(
  rav_drenthe = "rav_drenthe_querytool",
  rav_fryslan = "rav_fryslan_querytool",
  rav_limburg_noord = "rav_limburg_querytool"
)

for(database in names(querytool_users)) {
  querytool_user <- querytool_users[[database]]
  connections <- db_connect(database, preset = "postgres_production_admin")
  # connections$query(paste0("GRANT CONNECT ON DATABASE ", database, " TO \"", querytool_user, "\""), get = F)
  # connections$query(paste0("GRANT USAGE ON SCHEMA public TO \"", querytool_user, "\""), get = F)
  connections$query(paste0("GRANT SELECT ON ritten_edazng_raw TO \"", querytool_user, "\""), get = F)
  connections$disconnect()
}
