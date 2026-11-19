source("Library/init.R")

# Minimal reproduction of the el_qlik error in ambureports_knowledgebase_hourly:
#   unable to translate '.../sheets/0. Selecteer <U+00E9><U+00E9>n gemeente__pXmWH.json' to native encoding
#
# Cause: the container has no LANG, so every R process starts in the C locale (ASCII).
# Library/init.R fixes that for the current process with Sys.setlocale("LC_CTYPE", ...),
# but Sys.setlocale() does not carry over to new R processes. el_qlik downloads the export
# with AzureStor::multidownload_azure_file(), which runs the downloads in a background pool
# of fresh R processes (AzureRMR::init_pool() -> parallel::makeCluster(), PSOCK). Those are
# back in the C locale, and fail when they open a path containing "é" that came from the
# share listing (marked UTF-8). This script uses the same kind of PSOCK worker.
#
# Run from the reports folder, in the C locale like the scheduler container:
#   LANG=C LC_ALL= Rscript ~/RStudio/hello-world/scripts/knowledgebase_qlik_encoding_repro.R
#     -> main process: written, worker: error
#   LANG=en_US.UTF-8 Rscript ~/RStudio/hello-world/scripts/knowledgebase_qlik_encoding_repro.R
#     -> both written (what ENV LANG=en_US.UTF-8 in the image does)

write_sheet <- function(dir) {
  # Same shape as the Qlik API response: jsonlite marks non-ASCII strings as UTF-8
  sheet <- jsonlite::fromJSON('{"title": "0. Selecteer \\u00e9\\u00e9n gemeente", "id": "pXmWH"}')
  path <- file.path(dir, paste0(sheet$title, "__", sheet$id, ".json"))
  tryCatch({
    jsonlite::write_json(sheet, path)
    paste("written:", path)
  }, error = function(e) paste("ERROR:", conditionMessage(e)))
}

dir <- file.path(tempdir(), "sheets")
dir.create(dir, showWarnings = FALSE)

message("Main process   - LC_CTYPE: ", Sys.getlocale("LC_CTYPE"))
message("  ", write_sheet(dir))

cl <- parallel::makePSOCKcluster(1)
worker_locale <- parallel::clusterCall(cl, Sys.getlocale, "LC_CTYPE")[[1]]
message("Worker process - LC_CTYPE: ", worker_locale)
message("  ", parallel::clusterCall(cl, write_sheet, dir)[[1]])
parallel::stopCluster(cl)
