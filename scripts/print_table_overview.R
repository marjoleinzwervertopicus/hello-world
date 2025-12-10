source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
connections <- db_connect("rav_fryslan", preset = "postgres_development_server")
table_names <- connections$info$tables()$table
table_names <- table_names[!grepl("_backup$", table_names)]
table_names <- table_names[!grepl("^user", table_names)]

connections$query("SELECT patient_name FROM ambulance_task_edaz WHERE patient_name IS NOT NULL LIMIT 10 ")

for(table_name in table_names[1:5]) {
  column_names <- colnames(connections$table(table_name))
  cat("Tabel: ", table_name, "\nKolomnamen: ", paste0(column_names,  collapse = ", "), "\n\n")
  
  patient_columns <- column_names[grepl("patient|medewerker|geboortedatum|geslacht|naam", column_names)]
  if(length(patient_columns) > 0) cat("Waardes voor kolommen met woord 'patient':\n")
  for(column_name in patient_columns) {
    values <- connections$query(paste0("SELECT ", column_name, " FROM ", table_name, " WHERE ", column_name, " IS NOT NULL LIMIT 10"), echo = F)[[1]]
    cat(paste0("Waardes voor kolom '", column_name, "': ", paste0(values, collapse = ", "), "\n\n"))
  }
  cat("\n\n")
}

connections$disconnect()
