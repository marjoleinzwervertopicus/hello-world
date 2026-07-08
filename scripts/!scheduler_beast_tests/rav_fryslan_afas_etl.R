#For running locally. Needed for use with old Library/database/database.R
Sys.setenv("DEVISE_DB_USER" = "postgres")
Sys.setenv("DEVISE_DB_USER_MYSQL" = "devise")

source("Library/init.R")
get_contract_raw <- import("Library/clients/rav_fryslan/personnel/get_contract_raw.R")
prepare_contracts <- import("Library/clients/rav_fryslan/personnel/prepare_contracts.R")

get_contract_raw()
prepare_contracts()



