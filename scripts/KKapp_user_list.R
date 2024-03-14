source("Library/init.R")
database <- import("Library/database/database.R")
connections <- database$get_connections("kwaliteitskaderapp")
a <- connections$customer$get("SELECT user_info.email, provider.region FROM user_info LEFT JOIN provider ON provider.provider_id = user_info.provider_id")

write.csv(a, "kkapp_users.csv", row.names = FALSE)

