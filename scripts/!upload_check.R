library(lubridate)
library(dplyr)
library(tibble)

uploaded_files <- list.files("/home/devise/repos/production/Upload/uploaded/", recursive = TRUE, full.names = TRUE)
upload_users <- dirname(uploaded_files)
dates <- as.Date(substr(basename(uploaded_files), 1, 10))


last_upload <-  tibble(user = basename(upload_users), upload_date = dates) |> group_by(user) |> filter(upload_date == max(upload_date)) |> distinct() |> write.csv("laatste_uploads.csv")

overview <- tibble(file_name = basename(uploaded_files), user = upload_users, upload_date = dates, full_path = uploaded_files)

overview_filtered <- overview |> filter(upload_date > Sys.Date() %m-% months(3))
overview_filtered <- overview_filtered |> dplyr::arrange(upload_date)

# overview_filtered_aznn <- overview_filtered |> filter(grepl("AZNN|ROAZ", file_name))
# overview_filtered$file_name
# # file.remove(overview_filtered$full_path)
# 
# 
# user_folder_paths <- list.files("/srv/shiny-server/upload/uploaded", recursive = FALSE, full.names = TRUE)
# is_folder_empty <- map_lgl(user_folder_paths, ~length(list.files(., recursive = TRUE)) == 0)
# empty_folders <- user_folder_paths[is_folder_empty]
# basename(empty_folders)
# # file.remove(empty_folders)
# 
# 
# overview_filtered |> filter(upload_date < as.Date("2024-02-01")) |> select(user, file_name) |> mutate(user = basename(user)) |> View()
# 
# overview_filtered |> filter(upload_date < as.Date("2024-03-01")) |> select(user, file_name) |> mutate(user = basename(user)) |> View()
# 
# overview_filtered |> filter(upload_date >= as.Date("2024-03-01")) |> select(user, file_name) |> mutate(user = basename(user)) |> View()
# 
# overview_filtered_aznn |> select(user, file_name) |> mutate(user = basename(user)) |> View()

overview_filtered |> select(user, file_name) |> mutate(user = basename(user)) |> View()
