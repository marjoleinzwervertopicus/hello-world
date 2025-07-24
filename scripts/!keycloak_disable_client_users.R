source("Library/init.R")
keycloak_api <- import("utilities/keycloak_api.R")
lorenz_users <- keycloak_api$get_realm_role_users("jb_lorenz")

for(user_email in lorenz_users) {
  user_groups <- keycloak_api$get_user_groups(user_email)
  if(!identical(user_groups, "jb_lorenz")) {
    browser()
  } else {
    keycloak_api$remove_group_from_user(user_email, "jb_lorenz")
    keycloak_api$set_user_enable(user_email, FALSE)
  }
}

source("Library/init.R")
Sys.setenv("DEVISE_DB_USER" = "postgres")

db_connect <- import("Library/database/db_connect.R")
connections <- db_connect("jb_lorenz", preset = "postgres_application_server")
# connections$query("DROP DATABASE jb_lorenz")
connections$disconnect()


connections <- db_connect("rav_drenthe", preset = "postgres_etl_server")
connections$query("DROP DATABASE jb_lorenz")
connections$disconnect()

connections <- db_connect("shared", preset = "postgres_development_server")
connections$info$tables() |> View()
connections$disconnect()

