insight_config <- source("Library/utilities/insight_config.R")$value

production_upload_users <- insight_config$get_all_users(config_path = "/home/devise/configs/production/upload/users")$email

#deze ge
deleted_users <- c("b.jongkoen@ravijsselland.nl", "debby.dohmen@ggdzl.nl", "mark.beugels@ggdzl.nl", "mvanzundert@ambulancezorgln.nl")
production_upload_users <- upload_users[!upload_users %in% deleted_users]

uploaded_files <- list.files("/home/devise/repos/production/Upload/uploaded", recursive = TRUE, full.names = TRUE)
dates <- as.Date(substr(basename(uploaded_files), 1, 10))
upload_overview <- tibble(file_name = basename(uploaded_files), user = basename(dirname(uploaded_files)), upload_date = dates, full_path = uploaded_files)
users_uploaded_last_year <- upload_overview |> filter(upload_date > Sys.Date() %m-% years(1)) |> pull(user) |> unique()

keycloak_api <- source("~/RStudio/Upload/utilities/keycloak_api.R")$value
keycloak_groups <- map_lgl(production_upload_users, function(user_email) keycloak_api$get_user_groups(user_email))
user_info <- tibble(user_email = production_upload_users)
user_info$is_upload_only_user <- map_lgl(keycloak_groups, ~identical(., "upload"))
upload_only_users <- user_info |> filter(is_upload_only_user) |> pull(user_email)

user_to_2fa <- upload_only_users[upload_only_users %in% users_uploaded_last_year]

                                         