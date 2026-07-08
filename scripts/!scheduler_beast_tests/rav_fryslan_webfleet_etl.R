#For running locally. Needed for use with old Library/database/database.R
Sys.setenv("DEVISE_DB_USER" = "postgres")
Sys.setenv("DEVISE_DB_USER_MYSQL" = "devise")

source("Library/init.R")
extract_webfleet <- import("Library/clients/rav_fryslan/ambulance_tracks_webfleet/extract_script.R")
prepare_webfleet <- import("Library/clients/rav_fryslan/ambulance_tracks_webfleet/prepare_script.R")

extract_webfleet()
prepare_webfleet()


