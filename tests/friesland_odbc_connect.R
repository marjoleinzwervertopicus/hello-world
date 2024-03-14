source("Library/init.R")
secrets <- import("Library/utilities/secrets.R")
odbc <- RODBC::odbcConnect("anwb", uid = "device_analytics", pwd = secrets$get_for_shiny("anwb", "device_analytics"))
