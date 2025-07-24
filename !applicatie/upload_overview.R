library(lubridate)
library(dplyr)

uploaded_files <- list.files("/home/devise/repos/production/Upload/uploaded", recursive = TRUE, full.names = TRUE)
upload_users <- dirname(uploaded_files)
dates <- as.Date(substr(basename(uploaded_files), 1, 10))

overview <- tibble(file_name = basename(uploaded_files), user = upload_users, upload_date = dates, full_path = uploaded_files)

overview_filtered <- overview |> dplyr::arrange(desc(upload_date))

overview_filtered |> filter(upload_date >= as.Date("2024-04-01")) |> select(user, file_name) |> mutate(user = basename(user)) |> View()
