library(DBI)
secrets <- source("Library/utilities/secrets.R")$value

connection_args <- list(
  drv = odbc::odbc(), 
  Driver = "ODBC Driver 18 for SQL Server", 
  Server = "ambu-reports.database.windows.net",
  UID = "navadm",
  PWD = secrets$get("ambu-reports.database.windows.net", "navadm"),
  Encrypt = "Yes",
  timezone = "UTC", 
  timezone_out = Sys.timezone()
)

connection <- do.call(DBI::dbConnect, c(connection_args))


#does not work
table_name <- paste0("#tmp_", paste0(sample(c(letters, 0:9), 12, replace = T), collapse = ""))
dbWriteTable(
  conn = connection,
  name = SQL(table_name),
  value = data.frame(x = as.POSIXct(NA)),
  append = F,
  temporary = T
)


#does work
table_name <- paste0("#tmp_", paste0(sample(c(letters, 0:9), 12, replace = T), collapse = ""))
dbWriteTable(
  conn = connection,
  name = table_name,
  value = data.frame(x = as.POSIXct(NA)),
  append = F,
  temporary = T
)

# a <- dbGetQuery(connection, paste0("SELECT * FROM ", table_name))
# a |> as.tibble()

dbDisconnect(connection)



