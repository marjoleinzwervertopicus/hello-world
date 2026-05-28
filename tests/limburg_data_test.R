source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
connections <- db_connect("rav_limburg_zuid", preset = "postgres_etl_server")
connections_app <- db_connect("rav_limburg_zuid", preset = "postgres_application_server")

#12060 rijen, ts = CURRENT_TIMESTAMP
a <- connections$query("SELECT * FROM edaz_task_inbox where ts >= (select max(ts) - INTERVAL '120' MINUTE from edaz_task_inbox)")
a |> connections$write(table_name = "edaz_task_inbox_one_time_sync_2026")
a$ts |> max()
a$ts |> min()
test_raw <- connections_app$query("SELECT * FROM edaz_task_raw where ts >= (select max(ts) - INTERVAL '120' MINUTE from edaz_task_raw)")

edaz_task_raw

#67369
a <- connections$query("SELECT * FROM edaz_task_inbox_one_time_sync_2026")
b <- connections$query("SELECT * FROM edaz_form_inbox_one_time_sync_2026")

raw <- connections_app$query("SELECT * FROM edaz_task_raw")
nrow(b)
#


#Alles vanaf 2025-01-01

#11:32:13 eerste data

#01:35:24 - 01:36:15
c(min(a$ts), max(a$ts))

nrow(a)
test <- connections$query("SELECT * FROM edaz_form_inbox_one_time_sync_2026")
b <- connections$query("SELECT * FROM edaz_form_inbox where ts >= (select max(ts) - INTERVAL '180' MINUTE from edaz_form_inbox)")

b |> connections$write(table_name = "edaz_form_inbox_one_time_sync_2026")

#01:37:24 - 01:47:52
c(min(b$ts), max(b$ts))

b$timeupdated[grepl("2023", b$timeupdated)]


#170252
nrow(b)


# connections$query("SELECT column_name, column_default
# FROM information_schema.columns
# WHERE (table_schema, table_name) = ('public', 'edaz_task_inbox')
# ORDER BY ordinal_position;")
