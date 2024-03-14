date_filter <- c(Sys.Date() %m-% months(1), Sys.Date())
source("Library/init.R")




load_gms <- import("Library/clients/mk_limburg/dispatch_logistics/load_gms.R") 
files <- import("Library/utilities/files.R")
users <- files$load_files("Library/clients/mk_limburg/users.csv")
connections <- import("Library/database/database.R")$get_connections(c("mk_limburg", "rav_limburg_noord", "rav_limburg_zuid", "etl.mk_limburg", "geography"), persistent = TRUE)

gms <- load_gms(connections, date_filter, users)
