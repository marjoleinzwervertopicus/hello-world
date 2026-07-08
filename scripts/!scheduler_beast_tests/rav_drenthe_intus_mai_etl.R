#For running locally. Needed for use with old Library/database/database.R
Sys.setenv("DEVISE_DB_USER" = "postgres")
Sys.setenv("DEVISE_DB_USER_MYSQL" = "devise")

source("Library/init.R")
get_intus_contracts <- import("Library/modules/personnel/get_intus_raw.R")
prepare_hours <- import("Library/clients/rav_drenthe/personnel/prepare_hours.R")
prepare_psycholance <- import("Library/clients/rav_drenthe/psycholance/prepare_script.R")

get_intus_contracts("rav_drenthe", "drenthefrieslandanalyticsproductie")
prepare_hours(override = TRUE)

import("Library/modules/psycholance/transform.R")
prepare_psycholance()


