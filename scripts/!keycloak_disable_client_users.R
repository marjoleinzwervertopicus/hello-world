source("Library/init.R")
keycloak_api <- import("utilities/keycloak_api.R")

client_code <- "hap"

hap_users <- keycloak_api$get_realm_role_users(client_code)

for(user_email in hap_users) {
  user_groups <- keycloak_api$get_user_groups(user_email)
  if(all(user_groups %in% c(client_code, "upload"))) {
    keycloak_api$remove_group_from_user(user_email, client_code)
    
    if("upload" %in% user_groups) {
      keycloak_api$remove_group_from_user(user_email, "upload")
    }
    keycloak_api$set_user_enable(user_email, FALSE)
  } else {
    # print(user_email)
    # print(paste0(user_groups, collapse = ", "))
    keycloak_api$remove_group_from_user(user_email, client_code)
  }
}

source("Library/init.R")
Sys.setenv("DEVISE_DB_USER" = "postgres")

db_connect <- import("Library/database/db_connect.R")
connections <- db_connect("rav_drenthe", preset = "postgres_application_server")
# connections$query("DROP DATABASE mmt_umcg")
connections$disconnect()


connections <- db_connect("rav_drenthe", preset = "postgres_etl_server")
connections$query("DROP DATABASE mmt_umcg")
connections$disconnect()

connections <- db_connect("shared", preset = "postgres_development_server")
connections$info$tables() |> View()
connections$disconnect()

