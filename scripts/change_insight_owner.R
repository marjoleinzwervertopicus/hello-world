source("Library/init.R")
database <- import("Library/database/database.R")
user_emails_to_remove <- c("peter@meetdevise.nl", "felix@deviseanalytics.com")
new_owner_email <- "renco@meetdevise.com"

client <- "rav_drenthe"
for(client in client_names) {
  connections <- database$get_connections(client)
  old_user_ids <- connections$customer$get(paste0("SELECT user_id FROM user_info WHERE email IN ('", paste0(user_emails_to_remove, collapse = "', '"), "')"))$user_id
  new_user_id <- connections$customer$get(paste0("SELECT user_id FROM user_info WHERE email = '", new_owner_email, "'"))$user_id
  
  
  old_user_reports <- connections$customer$get(paste0("SELECT * FROM insight WHERE owner_id IN ('", paste0(old_user_ids, collapse = "', '"), "')"))
                                  
  connections$customer$set(paste0("UPDATE FROM insights SET owner_id = ", new_user_id, " WHERE owner_id IN ('", paste0(old_user_ids, collapse = "', '"), "')"
  
}