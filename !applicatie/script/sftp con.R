customer_code <- "rav_limburg_noord"
username <- "limburgnoorddeviseproductie"

get_script <- paste0(getwd(), "/Library/clients/", customer_code, "/personnel/get_personnel")
tryCatch(
  system(paste0("sftp -b ", get_script, " ", username, "@secureconnect.rooster.nl"), intern = TRUE),
  warning = function(w) {
    stop(w$message)
  }
)


#sftp -b /home/marjolein/RStudio/Platform/Library/clients/rav_limburg_noord/personnel/get_personnel limburgnoorddeviseproductie@secureconnect.rooster.nl