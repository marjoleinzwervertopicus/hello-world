source("Library/init.R")
keycloak_api <- import("utilities/keycloak_api.R")

email <- "marjolein@deviseanalytics.com"
email <- "marjolein_zwerver@hotmail.com"

keycloak_api$does_user_exist(email)
keycloak_api$does_user_exist("email")

groups <- keycloak_api$get_user_groups(email)
groups

keycloak_api$add_user("test@devise.nl", "test", "upload")
keycloak_api$remove_user("test@devise.nl")

keycloak_api$edit_user_first_name(email, "m test")
keycloak_api$add_group_to_user(email, "upload")
keycloak_api$remove_group_from_user(email, "upload")

keycloak_api$send_create_password_mail(email, "https://upload.devise.cloud/")



#Platform only
keycloak_api$get_users_missing_realm_role()

keycloak_api$set_user_enable(email, FALSE)
keycloak_api$is_user_disabled(email)
keycloak_api$set_user_enable(email, TRUE)
keycloak_api$is_user_disabled(email)
keycloak_api$set_user_email_verified(email)


#errors

#api call gives 400 bad request error
keycloak_api$send_create_password_mail(email, "test")

#These calls create errors we added to the code
keycloak_api$add_group_to_user(email, "upload2")
keycloak_api$remove_group_from_user(email, "upload2")
keycloak_api$get_user_groups("jkhdkjash@devise.nl")
result <- keycloak_api$add_user("marjolein_zwerver@hotmail.com", "test", "upload")

#test that gives 1 error
keycloak_api$add_user("aaaaaaaaaaaaaaaaaaaaaaaa", "test", "upload")

#test that gives 3 errors
keycloak_api$add_user("~", "test", "upload")


