# Vervangt preset postgres_application_server door postgres_production in de
# opgeslagen queries van de query_tool, en in de query_tool app.yml zelf, voor alle
# klantmappen binnen een environment:
#   /home/devise/insights/[environment]/[klant map]/queries/*.yml
#   /home/devise/insights/[environment]/[klant map]/query_tool/app.yml
# Voer voor test uit in rstudio-devise, en voor productie in rstudio-admin
environment <- "test"
insights_dir <- file.path("/home/devise/insights", environment)
old_preset <- "postgres_application_server"
new_preset <- "postgres_production"
dry_run <- F

if (!dir.exists(insights_dir)) stop("Map bestaat niet: ", insights_dir)

pattern <- paste0("^(\\s*preset:\\s*['\"]?)", old_preset, "(['\"]?\\s*)$")

replace_preset_in_file <- function(file, label) {
  lines <- readLines(file, warn = FALSE)
  matches <- grepl(pattern, lines)

  if (any(matches)) {
    message(
      if (dry_run) "[dry run] " else "",
      label, ": ", sum(matches), " vervanging(en)"
    )
    if (!dry_run) {
      lines[matches] <- sub(pattern, paste0("\\1", new_preset, "\\2"), lines[matches])
      writeLines(lines, file)
    }
  }
}

client_dirs <- list.dirs(insights_dir, recursive = FALSE)

for (client_dir in client_dirs) {
  client_name <- basename(client_dir)

  queries_dir <- file.path(client_dir, "queries")
  if (dir.exists(queries_dir)) {
    yml_files <- list.files(queries_dir, pattern = "\\.ya?ml$", full.names = TRUE)
    for (file in yml_files) {
      replace_preset_in_file(file, paste0(client_name, "/queries/", basename(file)))
    }
  }

  app_yml <- file.path(client_dir, "query_tool", "app.yml")
  if (file.exists(app_yml)) {
    replace_preset_in_file(app_yml, paste0(client_name, "/query_tool/app.yml"))
  }
}
