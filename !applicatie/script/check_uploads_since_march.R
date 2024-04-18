upload_users <- basename(list.dirs("/srv/shiny-server/upload/uploaded/"))
has_upload_after_march <- map_lgl(upload_users, function(user) {
  user_upload_files <- list.files(paste0("/srv/shiny-server/upload/uploaded/", user), full.names = T)
  if(!is_empty(user_upload_files)) any(file.info(user_upload_files)$mtime > as.Date("2024-03-01")) else FALSE
}) %>% setNames(upload_users)

users_with_upload_after_march <- names(has_upload_after_march[has_upload_after_march])

names(has_upload_after_march[!has_upload_after_march])

paste0(users_with_upload_after_march, collapse = ", ")
