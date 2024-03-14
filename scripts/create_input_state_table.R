source("Library/init.R")
database <- import("Library/database/database.R")

connections <- database$get_connections("rav_limburg")

connections$customer$set("CREATE TABLE input_state (
                user_email character varying,
                value text,
                date date
                );")


connections$customer$set("CREATE UNIQUE INDEX user_email_index ON input_state(user_email)")


# query_text <- "INSERT INTO input_state (user_email, value, date, user_id, name) VALUES (?user_email, ?value, ?date, 0, 'dummy') ON CONFLICT(user_email) DO UPDATE SET value = ?value, date = ?date"
