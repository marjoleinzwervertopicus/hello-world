uploaded_files <- list.files("/srv/shiny-server/upload/uploaded/", recursive = TRUE)
upload_users <- dirname(uploaded_files)
dates <- as.Date(substr(basename(uploaded_files), 1, 10))

overview <- tibble(file_name = basename(uploaded_files), user = upload_users, upload_date = dates)
overview <- overview %>% arrange(upload_date)

