library(db)
Sys.setenv("DEVISE_DB_USER" = "postgres")
# checks that every database and table dumped by simple_dump.sh exists on the target server
# and has the same number of rows as on the source server
# (row counts only match when nothing has written to the source since the dump, so stop the ETL first)
source_preset <- "postgres_application_admin"
target_preset <- "postgres_production"
dump_script <- "~/RStudio/hello-world/db_export/simple_dump.sh"

# parse the "dump_db <database> <table> <table> ..." lines of simple_dump.sh
dump_lines <- grep("^\\s*dump_db\\s+", readLines(dump_script), value = TRUE)
dump_words <- strsplit(trimws(dump_lines), "\\s+")
expected_tables_per_db <- setNames(
  lapply(dump_words, function(words) words[-(1:2)]),
  vapply(dump_words, `[`, character(1), 2)
)

# list all databases on a server (via any existing database)
server_databases <- function(preset) {
  connections <- db_connect("rav_drenthe", preset = preset)
  on.exit(connections$disconnect())
  connections$query(
    "SELECT datname FROM pg_database
     WHERE datistemplate = false AND datallowconn = true"
  )$datname
}

# all relations pg_dump --table can match (tables, views, materialized views, foreign and partitioned tables)
read_relations <- function(connections) {
  connections$query(
    "SELECT n.nspname AS schema_name, c.relname AS table_name
     FROM pg_class c
     JOIN pg_namespace n ON n.oid = c.relnamespace
     WHERE c.relkind IN ('r', 'p', 'v', 'm', 'f')
       AND n.nspname NOT IN ('pg_catalog', 'information_schema')"
  )
}

# unqualified names in pg_dump --table match any schema, qualified names match schema.table;
# returns the matching schema.table names (empty when the table does not exist)
resolve_table <- function(table, relations) {
  qualified <- paste0(relations$schema_name, ".", relations$table_name)
  if (grepl(".", table, fixed = TRUE)) qualified[qualified == table] else qualified[relations$table_name == table]
}

quote_ident <- function(name) paste0('"', gsub('"', '""', name, fixed = TRUE), '"')

count_rows <- function(connections, qualified_table) {
  parts <- strsplit(qualified_table, ".", fixed = TRUE)[[1]]
  sql <- paste0("SELECT count(*) AS n FROM ", quote_ident(parts[1]), ".", quote_ident(parts[2]))
  as.numeric(connections$query(sql)$n)
}

source_dbs <- server_databases(source_preset)
target_dbs <- server_databases(target_preset)

missing_dbs <- setdiff(names(expected_tables_per_db), target_dbs)
missing_source_dbs <- setdiff(names(expected_tables_per_db), source_dbs)
missing_tables <- list()
missing_source_tables <- list()
row_counts <- list()

for (db_name in intersect(intersect(names(expected_tables_per_db), target_dbs), source_dbs)) {
  message("Checking ", db_name, "...")
  source_connections <- NULL
  target_connections <- NULL
  result <- tryCatch({
    source_connections <- db_connect(db_name, preset = source_preset)
    target_connections <- db_connect(db_name, preset = target_preset)
    source_relations <- read_relations(source_connections)
    target_relations <- read_relations(target_connections)

    db_missing <- character(0)
    db_missing_source <- character(0)
    db_counts <- list()
    for (table in expected_tables_per_db[[db_name]]) {
      source_tables <- resolve_table(table, source_relations)
      target_tables <- resolve_table(table, target_relations)
      if (length(target_tables) == 0) db_missing <- c(db_missing, table)
      if (length(source_tables) == 0) db_missing_source <- c(db_missing_source, table)

      for (qualified_table in union(source_tables, target_tables)) {
        db_counts[[length(db_counts) + 1]] <- data.frame(
          database = db_name,
          table = qualified_table,
          source_rows = if (qualified_table %in% source_tables) count_rows(source_connections, qualified_table) else NA,
          target_rows = if (qualified_table %in% target_tables) count_rows(target_connections, qualified_table) else NA
        )
      }
    }
    list(missing = db_missing, missing_source = db_missing_source, counts = do.call(rbind, db_counts))
  }, error = function(e) {
    message("Could not check ", db_name, ": ", conditionMessage(e))
    NULL
  }, finally = {
    if (!is.null(source_connections)) source_connections$disconnect()
    if (!is.null(target_connections)) target_connections$disconnect()
  })

  if (is.null(result)) {
    missing_dbs <- c(missing_dbs, db_name)
    next
  }

  if (length(result$missing) > 0) missing_tables[[db_name]] <- result$missing
  if (length(result$missing_source) > 0) missing_source_tables[[db_name]] <- result$missing_source
  row_counts[[db_name]] <- result$counts
}

row_counts <- do.call(rbind, row_counts)
if (is.null(row_counts)) {
  row_counts <- data.frame(database = character(0), table = character(0), source_rows = numeric(0), target_rows = numeric(0))
}
rownames(row_counts) <- NULL
row_count_differences <- row_counts[
  !is.na(row_counts$source_rows) & !is.na(row_counts$target_rows) &
    row_counts$source_rows != row_counts$target_rows, ]

n_tables <- sum(lengths(expected_tables_per_db))
cat("Checked ", length(expected_tables_per_db), " databases and ", n_tables, " tables from ", dump_script,
    " (source: ", source_preset, ", target: ", target_preset, ")\n", sep = "")

if (length(missing_dbs) > 0) {
  cat("\nMissing or unreachable databases on target:\n", paste0("  ", missing_dbs, "\n"), sep = "")
}
if (length(missing_source_dbs) > 0) {
  cat("\nMissing databases on source:\n", paste0("  ", missing_source_dbs, "\n"), sep = "")
}
if (length(missing_tables) > 0) {
  cat("\nMissing tables on target:\n")
  for (db_name in names(missing_tables)) {
    cat("  ", db_name, ": ", paste(missing_tables[[db_name]], collapse = ", "), "\n", sep = "")
  }
}
if (length(missing_source_tables) > 0) {
  cat("\nTables in ", basename(dump_script), " that do not exist on source:\n", sep = "")
  for (db_name in names(missing_source_tables)) {
    cat("  ", db_name, ": ", paste(missing_source_tables[[db_name]], collapse = ", "), "\n", sep = "")
  }
}
if (nrow(row_count_differences) > 0) {
  cat("\nRow count differences:\n")
  print(transform(row_count_differences, difference = target_rows - source_rows), row.names = FALSE)
}

all_ok <- length(missing_dbs) == 0 && length(missing_source_dbs) == 0 && length(missing_tables) == 0 &&
  length(missing_source_tables) == 0 && nrow(row_count_differences) == 0
if (all_ok) {
  cat("All databases and tables are present with equal row counts.\n")
}
