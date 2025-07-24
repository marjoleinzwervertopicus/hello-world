source("Library/init.R")
keycloak_api <- import("utilities/keycloak_api.R")
files <- import("Library/utilities/files.R")
insight_configs <- import("utilities/insight_config.R")

all_user_info <- files$load_file("~/RStudio/reports/clients/rav_drenthe/dashboards/medewerker_rmd/user_info_rav_fryslan.csv")
all_user_info <- all_user_info |> select(user_email = email, name) |> distinct(user_email, .keep_all = TRUE)

#remove last name and extra first names
all_user_info <- all_user_info |> mutate(first_name = gsub( " .*$", "", name)) |> select(-name)

#Replace special characters in first name for keycloak user to prevent error when sending password reset mail
all_user_info <- all_user_info |> mutate(first_name = stringi::stri_trans_general(str = first_name, id = "Latin-ASCII"))

all_user_info |> View()


# all_user_info_test <- tibble(
#   user_email = c("marjolein@devise.nl", "marjolein_zwerver@hotmail.com", "marjolein.zwerver@topicus.nl"),
#   first_name = c("Marjolein", "marjolein test 1", "marjolein test 2")
# )

for(i in seq_len(nrow(all_user_info))) {
  user_info <- all_user_info[i, ]
  
  
  add_user_config <- TRUE
  if(!keycloak_api$does_user_exist(user_info$user_email)) {
    warning(paste0("User '", user_info$user_email, "' created with name ", user_info$first_name))
    keycloak_api$add_user(user_info$user_email, user_info$first_name, "rav_fryslan")
  } else if(!"rav_fryslan" %in% keycloak_api$get_user_groups(user_info$user_email)) {
    warning("user for email ", user_info$user_email, " exists but lacks group ra_fryslan")
    keycloak_api$add_group_to_user(user_info$user_email, "rav_fryslan")
  } else {
    add_user_config <- FALSE
    warning(paste0("User '", user_info$user_email, "' already exists"))
  }
  
  if(add_user_config) {
    config <- list(name = user_info$first_name, email = user_info$user_email, is_devise = FALSE, is_admin = FALSE)
    insight_configs$add_new_user(config)
  }
}

