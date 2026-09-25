library(db)
# writes every database on the development server with all its tables to dev_tables.txt
preset <- "postgres_development_server"
output_file <- "dev_tables.txt"

# list all databases on the server (via any existing database)
connections <- db_connect("rav_drenthe", preset = preset)
db_names <- connections$query(
  "SELECT datname FROM pg_database
   WHERE datistemplate = false AND datallowconn = true
   ORDER BY datname"
)$datname
connections$disconnect()

lines <- character(0)

for (db_name in db_names) {
  connections <- NULL
  tables <- tryCatch({
    connections <- db_connect(db_name, preset = preset)
    connections$query(
      "SELECT CASE WHEN table_schema = 'public' THEN table_name
                   ELSE table_schema || '.' || table_name END AS name
       FROM information_schema.tables
       WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
       ORDER BY table_schema, table_name"
    )$name
  }, error = function(e) {
    message("Could not read tables for ", db_name, ": ", conditionMessage(e))
    NULL
  }, finally = {
    if (!is.null(connections)) connections$disconnect()
  })

  lines <- c(lines, paste0("Database: ", db_name))
  if (is.null(tables)) {
    lines <- c(lines, "  <could not connect>")
  } else if (length(tables) == 0) {
    lines <- c(lines, "  <no tables>")
  } else {
    lines <- c(lines, paste0("  ", tables))
  }
  lines <- c(lines, "")
}

writeLines(lines, output_file)
cat("Written ", length(db_names), " databases to ", normalizePath(output_file), "\n")
