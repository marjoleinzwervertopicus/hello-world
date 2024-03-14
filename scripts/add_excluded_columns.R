source("Library/init.R")
database <- import("Library/database/database.R")
connections <- database$get_connections("roaz_aznn")
files <- import("Library/utilities/files.R")


add_rows <- function(csv_path, roaz_table_name) {
  column_names_table <- connections$customer$show_columns(roaz_table_name)$column_name
  csv_table <- files$load_file(csv_path, all_characters = F)
  column_names_csv <- csv_table$name
  
  
  if(any(!column_names_csv %in% column_names_table)) {
    non_existing_column_names <- column_names_csv[!column_names_csv %in% column_names_table]
    browser()
  }
  
  if(any(duplicated(column_names_csv))) {
    duplicated_columns <- column_names_csv[duplicated(column_names_csv)]
    browser()
  }
  
  missing_column_names <- column_names_table[!column_names_table %in% column_names_csv]
  
  if(!is_empty(missing_column_names)) {
    # missing_data <- csv_table[0, ]
    # missing_data$table_name <- roaz_table_name
    # missing_data$name <- missing_column_names
    #, name = missing_column_names, exclude = TRUE)
    
    missing_data <- tibble(table_name = roaz_table_name, name = missing_column_names, exclude = TRUE)
    missing_data <- bind_rows(csv_table[0, ], missing_data)
    # files$write_csv(completed_table, csv_path, quote = T, convert_encoding = F, )
    write.table(x = missing_data, file = csv_path, sep = ";", dec = ".", row.names = F, na = "", quote = FALSE, append = TRUE, col.names = FALSE)
  }
}


add_rows("Library/clients/roaz_aznn/ziekenhuizen/metadata/variables.csv", "roaz_ziekenhuizen")
add_rows("Library/clients/roaz_aznn/ambulances/metadata/variables.csv", "roaz_ambulances")
add_rows("Library/clients/roaz_aznn/haps/metadata/variables.csv", "roaz_haps")
add_rows("Library/clients/roaz_aznn/ketenzorg/metadata/variables.csv", "roaz_ketenzorg")


