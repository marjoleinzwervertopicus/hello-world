#Run with Upload as wd
# setwd("../Upload")
source("Library/init.R")

library(htmltools)
email_sender <- import("utilities/email/email_sender.R")
keycloak_api <- import("utilities/keycloak_api.R")

for(i in 1:50) {
  #one keycloak api call seems to make error very uncommon (40 mails sent without error with 'does_user_exist' call only)
  #two keycloak api calls seems to make error very common (0 or 1 email sent before error)
  keycloak_api$get_user_groups("marjolein@deviseanalytics.com")
  keycloak_api$does_user_exist("marjolein@deviseanalytics.com")
  warning("before send email")
  
  tryCatch({
  email_sender(
    template_folder = "new_app_upload",
    subject = "Welkom bij de uploadtool van Devise!",
    email_receivers = "marjolein@deviseanalytics.com",
    variables = list()
  )
  }, error = function(e) {
    browser()
  })
}

# system("Rscript keycloak_call.R")
# source("Library/init.R")
# keycloak_api <- import("utilities/keycloak_api.R")
# keycloak_api$add_group_to_user("marjolein@deviseanalytics.com", "upload")

