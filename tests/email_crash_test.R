source("Library/init.R")

library(htmltools)
email_sender <- import("utilities/email/email_sender.R")
keycloak_api <- import("utilities/keycloak_api.R")


# keycloak_api$get_user_groups("marjolein@deviseanalytics.com")

warning("before send email")

email_sender(
  template_folder = "new_app_upload",
  subject = "Welkom bij de uploadtool van Devise!",
  email_receivers = "marjolein@deviseanalytics.com",
  variables = list()
)

system("Rscript keycloak_call.R")
source("Library/init.R")
keycloak_api <- import("utilities/keycloak_api.R")
keycloak_api$add_group_to_user("marjolein@deviseanalytics.com", "upload")

