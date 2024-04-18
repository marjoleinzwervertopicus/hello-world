source("Library/init.R")
secrets <- import("Library/utilities/secrets.R")
odbc <- RODBC::odbcConnect("anwb_test5", uid = "device_analytics", pwd = "Aich9oyoojie9toom9WaaxaK")

# RODBC::odbcConnect()
