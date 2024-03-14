... <- (function() {
  load <- source("load.R")$value
  load("RODBC")
  load("DBI")
  load("RPostgres")
  
  this <- list(
    postgresql_dsn = function(dsn) {
      list(
        query = function(query) {
          odbc <- odbcConnect(dsn)
          result <- sqlQuery(odbc, query)
          odbcClose(odbc)
          
          result
        },
        insert_table = function(table_name, dataset) {
          odbc <- odbcConnect(dsn)
          dataset[] <- lapply(dataset, as.character)
          table_exists <- sqlQuery(odbc, paste0("SELECT COUNT(*) > 0 AS exists FROM information_schema.tables WHERE table_name = '", output_config$table_name, "'"))$exists
          dataset$ts <- as.character(Sys.time())
          
          sqlSave(odbc, dat = dataset, tablename = table_name, rownames = FALSE, append = TRUE, verbose = TRUE)
          odbcClose(odbc)
        }
      )
    },
    
    sql_server = function(driver, host, port, database, user, password) {
      if(is.null(port)) {
        port <- "1433"
      }
      if(is.null(driver)) {
        driver <- "/opt/microsoft/msodbcsql17/lib64/libmsodbcsql-17.8.so.1.1"
      }
      connection_string <- paste0("driver=", driver, ";server=", host, ";port=", port, ";database=", database, ";uid=", user, ";pwd=", password)
      
      list(
        query = function(query) {
          odbc <- odbcDriverConnect(connection_string)
          result <- sqlQuery(odbc, query, as.is = TRUE)
          odbcClose(odbc)
          
          result
        }
      )
    }
  )
})()