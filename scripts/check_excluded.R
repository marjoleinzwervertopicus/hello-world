source("Library/init.R")
all_variable_files <- list.files(pattern = "^variables.csv$", recursive = TRUE)
files <- import("Library/utilities/files.R")

for(file_name in all_variable_files) {
  variable_tibble <- files$load_file(file_name)
  if(any(!is.na(variable_tibble$exclude_users))) browser()
}
