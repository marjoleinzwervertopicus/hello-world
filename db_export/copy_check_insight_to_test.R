# Kopieert het inzicht check_postgres_application_server naar alle klantmappen binnen test:
#   /home/devise/insights/test/[klant map]/check_postgres_application_server/
# Alleen de html en html.yml worden gekopieerd (de Rmd is niet nodig om het inzicht te openen).
# Bestaande bestanden worden overschreven. Zet dry_run op FALSE om echt te kopiëren.
insight_dir <- "~/RStudio/Platform/insights/check_postgres_application_server"
insights_dir <- "/home/devise/insights/test"
dry_run <- F

insight_name <- basename(insight_dir)
insight_files <- file.path(insight_dir, paste0(insight_name, c(".html", ".html.yml")))

if (!dir.exists(insights_dir)) stop("Map bestaat niet: ", insights_dir)
missing_files <- insight_files[!file.exists(insight_files)]
if (length(missing_files) > 0) stop("Bestand(en) niet gevonden: ", paste(missing_files, collapse = ", "))

client_dirs <- list.dirs(insights_dir, recursive = FALSE)
client_dirs <- client_dirs[!grepl("demo$|hap$|devise$", client_dirs)]

for (client_dir in client_dirs) {
  dest <- file.path(client_dir, insight_name)

  if (dry_run) {
    message("[dry run] ", insight_dir, " -> ", dest)
  } else {
    message(insight_dir, " -> ", dest)
    dir.create(dest, showWarnings = FALSE)
    ok <- file.copy(insight_files, dest, overwrite = TRUE, copy.date = TRUE)
    if (!all(ok)) warning("Kopiëren mislukt naar: ", dest)
  }
}
