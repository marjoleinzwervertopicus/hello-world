source("Library/init.R") 
Sys.setenv("DEVISE_DB_USER" = "postgres")
database <- import("Library/database/database.R")
connections <- database$get_connections("lazk", host = "postgres_application_server")
all_logins <- connections$customer$get("SELECT * FROM client_info")
logins_no_devise <- all_logins |> filter(!str_detect(user_email, regex("@devise|@meetdevise", ignore_case = TRUE)))
logins_no_devise$maand <- format(logins_no_devise$time_login, "%Y-%m")

public_logins <- logins_no_devise |> filter(user_email == "PUBLIC_USER") |> select(maand)
public_logins$name <- "publiek"
private_logins <- logins_no_devise |> filter(user_email != "PUBLIC_USER") |> select(maand)
private_logins$name <- "niet-publiek"

logins <- bind_rows(public_logins, private_logins)

logins_table <- logins |> group_by(maand, name) |> summarize(n = n()) |> pivot_wider(names_from = "name", values_from = "n", values_fill = 0) |> arrange(maand)
logins_table |> write.table("lazk_logins.csv", sep = ";", row.names = F)
