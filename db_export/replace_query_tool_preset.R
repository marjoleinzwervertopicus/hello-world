# Vervangt preset postgres_application_server door postgres_production in de
# opgeslagen queries van de query_tool, voor alle klantmappen binnen een environment
# (/home/devisee/insights/[environment]/[klant map]/queries). Tekstvervanging i.p.v.
# yaml inlezen/wegschrijven, zodat de rest van de yml (bv. .na-waarden) ongewijzigd blijft.
environment <- "test"
insights_dir <- file.path("/home/devise/insights", environment)
old_preset <- "postgres_application_server"
new_preset <- "postgres_production"
dry_run <- TRUE

if (!dir.exists(insights_dir)) stop("Map bestaat niet: ", insights_dir)

pattern <- paste0("^(\\s*preset:\\s*['\"]?)", old_preset, "(['\"]?\\s*)$")
client_dirs <- list.dirs(insights_dir, recursive = FALSE)

for (client_dir in client_dirs) {
  queries_dir <- file.path(client_dir, "queries")
  if (!dir.exists(queries_dir)) next

  yml_files <- list.files(queries_dir, pattern = "\\.ya?ml$", full.names = TRUE)

  for (file in yml_files) {
    lines <- readLines(file, warn = FALSE)
    matches <- grepl(pattern, lines)

    if (any(matches)) {
      message(
        if (dry_run) "[dry run] " else "",
        basename(client_dir), "/", basename(file), ": ", sum(matches), " vervanging(en)"
      )
      # if (!dry_run) {
      #   lines[matches] <- sub(pattern, paste0("\\1", new_preset, "\\2"), lines[matches])
      #   writeLines(lines, file)
      # }
    }
  }
}
