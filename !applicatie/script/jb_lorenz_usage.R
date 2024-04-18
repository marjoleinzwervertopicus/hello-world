# source("Library/init.R")
# database <- import("Library/database/database.R")
# connections <- database$get_connections("devise")
# 
# login_info <- connections$customer$get("SELECT * FROM user_statistics WHERE customer_code = 'jb_lorenz' AND ts > '2024-01-01'")


lorenz_files_2024 <- list.files("/var/log/shiny-server/", "^jb_lorenz-shiny-202(4|4).*", full.names = T)

all_users <- tibble(users = map_chr(lorenz_files_2024, function(file_path) {
  file_content <- read.delim(file_path, header = FALSE)
  info_line <- file_content[which(apply(file_content, 1, function(line) grepl("select \\* from user_info where email = ", line)))[1], ]
  user_email <- str_replace(info_line, "^Querying: select \\* from user_info where email = '", "")
  user_email <- substr(user_email, 0, nchar(user_email) - 2)
  # if(is.na(user_email)) browser()
  user_email
})) |> group_by(users) |> summarize(n = n())

users <- all_users |> filter(!is.na(users), !users %in% c("marjolein@deviseanalytics.com", "warner@jblorenz.nl", "joanna@deviseanalytics.com"))
users <- users[!users %in% c("marjolein@deviseanalytics.com", "warner@jblorenz.nl", "joanna@deviseanalytics.com")]

user_gemeentes <- tibble( users = c(
  "b.jansen@bergenopzoom.nl",
  "bianca@jblorenz.nl",
  "g.bertram@gemeentehulst.nl",
  "l.stoevenbeld@pijnacker-nootdorp.nl",
  "lara.huisman@ommen.nl",
  "marco@jblorenz.nl"
  
), gemeentes = c(
  "Ommen",
  "Pijnacker-Nootdorp",
  "Hulst",
  "Pijnacker-Nootdorp",
  "Ommen",
  "Hulst"
))

gemeentes <- left_join(users, user_gemeentes) |> select(-users)

gemeentes |> group_by(gemeentes) |> summarize(`aantal logins` = sum(n))

