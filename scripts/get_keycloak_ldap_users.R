source("Library/init.R")
keycloak_api <- import("utilities/keycloak_api.R")

# users <- keycloak_api$get_all_ldap_only_users()
users <- keycloak_api$get_disabled_users()


saveRDS(users, "disabled_users.RDS")

# ldap_only_users2 <- ldap_only_users[grepl("@", ldap_only_users )]


# source("Library/init.R")
# keycloak_api$does_user_have_local_password("joanna@deviseanalytics.com")
