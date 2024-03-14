files <- import("Library/utilities/files.R")
calculate_metadata_files <- list.files("Library/clients/roaz_aznn", ".*calculates.csv", recursive = T, full.names = T)


remove_category_column <- function(metadata_file) {
  dataset <- files$load_file(metadata_file)
  # if("category" %in% colnames(dataset)) {
    dataset <- dataset %>% select(-category)
  # }
  files$write_csv(dataset, metadata_file, quote = FALSE)
  
}

for(file in calculate_metadata_files) remove_category_column(file)
metadata_file <- calculate_metadata_files[14]
#14
# remove_category_column("~/RStudio/Platform/Library/clients/rav_drenthe/personnel/metadata/calculates.csv")
# calculates <- read_delim("Library/clients/rav_drenthe/personnel/metadata/calculates.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE)
# message(paste0("\"", paste0(calculates$name, collapse = "\",\n\""), "\""))
