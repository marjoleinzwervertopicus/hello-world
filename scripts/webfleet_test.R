source("Library/init.R")
extract <- import("Library/clients/rav_fryslan/ambulance_tracks_webfleet/extract.R")

client <- "etl.rav_fryslan"
connections <- import("Library/database/database.R")$get_connections(client)

secrets <- import("Library/utilities/secrets.R")
secret <- secrets$get("webfleet", "kijlstra")
base_webfleet_url <- 
  paste0("https://csv.webfleet.com/extern?", secret, "&lang=nl&outputformat=json")

max_date_show_standstills <- 
  date(pull(connections[[client]]$get("SELECT MAX(date_time) FROM show_standstills_webfleet")))
date_filter_show_standstills <- c(max_date_show_standstills %m-% days(2), Sys.Date())

#current
show_standstills_new <-
  extract$show_standstills(date_filter = date_filter_show_standstills,
                           base_webfleet_url = base_webfleet_url)

#new
show_standstills_new <-
  extract$show_standstills(date_filter = date_filter_show_standstills)


str_split(secret, pattern = "=")




