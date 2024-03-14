source("Library/init.R")
database <- import("Library/database/database.R")
connections <- database$get_connections("rav_drenthe")

a <- connections$customer$get("SELECT * FROM client_info")
# a <- a %>% filter(time_login > as.POSIXct("2023-01-01 00:00:00"))
browser_counts <- a %>% 
  filter(time_login > as.POSIXct("2023-01-01 00:00:00")) %>%
  group_by(browser) %>% 
  summarize(n = n())


firefox_users <- a %>% 
  filter(time_login > as.POSIXct("2023-01-01 00:00:00"))


firefox_users <- unique(firefox_users$user_email[grepl("Firefox", firefox_users$browser)])
