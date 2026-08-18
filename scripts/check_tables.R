source("Library/init.R")
Sys.setenv("DEVISE_DB_USER" = "postgres")

connections <- db_connect("rav_limburg_zuid", preset = "postgres_application_server")
tables <- connections$info$tables()

excluded <- paste0("public.", c("dashboard", "data_statistics", "data_summary", "email_queue", "flag", "guide", "input_state", "insight",
                                "message", "message_user", "metadata_calculate", "metadata_variable",
              "user_dashboard", "usergroup", "user_group", "user_group_insight", "user_guide", "user_info", "user_insight", "user_message",
              "user_metadata_calculate", "user_metadata_variable", "user_statistics", "user_user_group"))

message(
  paste0(
    tables$table_name[!tables$table_name %in% excluded], collapse = "\n")
)

connections$disconnect()

# connections <- db_connect("rav_brabant_zuidoost", preset = "postgres_application_server")
# connections$query("SELECT * FROM accountvalues_raw")
# connections$disconnect()