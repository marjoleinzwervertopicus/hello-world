source("Library/init.R")
keycloak_api <- import("utilities/keycloak_api.R")
files <- import("Library/utilities/files.R")
insight_configs <- import("utilities/insight_config.R")

all_user_info <- files$load_file("~/RStudio/reports/clients/rav_drenthe/dashboards/medewerker_rmd/user_info_rav_drenthe.csv")
all_user_info <- all_user_info |> select(user_email = email, name) |> distinct(user_email, .keep_all = TRUE)
all_user_info <- all_user_info |> mutate(first_name = gsub( " .*$", "", name)) |> select(-name)

# all_user_info_test <- tibble(
#   user_email = c("marjolein@devise.nl", "marjolein_zwerver@hotmail.com", "marjolein.zwerver@topicus.nl"),
#   first_name = c("Marjolein", "marjolein test 1", "marjolein test 2")
# )

for(i in seq_len(nrow(all_user_info))) {
  user_info <- all_user_info[i, ]
  
  if(!keycloak_api$does_user_exist(user_info$user_email)) {
    # warning(paste0("User '", user_info$user_email, "' created"))
    keycloak_api$add_user(user_info$user_email, user_info$first_name, "rav_drenthe")
  } else if(!"rav_drenthe" %in% keycloak_api$get_user_groups(user_info$user_email)) {
    keycloak_api$add_group_to_user(user_info$user_email, "rav_drenthe")
  } else {
    warning(paste0("User '", user_info$user_email, "' already exists"))
  }
  
  config <- list(name = user_info$first_name, email = user_info$user_email, is_devise = FALSE, is_admin = FALSE)
  insight_configs$add_new_user(config)
}

