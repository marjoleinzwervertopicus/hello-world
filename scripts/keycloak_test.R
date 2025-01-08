source("Library/init.R")
keycloak_api <- import("utilities/keycloak_api.R")

keycloak_api$send_create_password_mail("marjolein_zwerver@hotmail.com", "https://ravfr.devise.cloud")


keycloak_api$does_user_exist("marjolein_zwerver@hotmail.com")

keycloak_api$add_user("marjolein_zwerver@hotmail.com", "Marjolein", "rav_drenthe")

keycloak_api$add_group_to_user("marjolein_zwerver@hotmail.com", "rav_fryslan")
groups <- keycloak_api$get_user_groups("marjolein_zwerver@hotmail.com")
keycloak_api$remove_group_from_user("marjolein_zwerver@hotmail.com", "rav_fryslan")

keycloak_api$edit_user_first_name("marjolein_zwerver@hotmail.com", "m test")
keycloak_api$remove_user("marjolein_zwerver@hotmail.com")


