source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
connections <- db_connect("rav_limburg_zuid", preset = "postgres_development_server")
a <- connections$query("SELECT * FROM ambulance_task_edaz WHERE receive_task_date = '2026-01-01'")
a |> select(rit_id_gms, edaz_task_raw_id, edaz_id, incident_id_drfrit_edaz, incident_id_gms_edaz, task_id, task_id_edaz) |> View()


b <- connections$query("SELECT * FROM edaz_task_raw LIMIT 1")

b <- connections$query("SELECT * FROM edaz_task_raw WHERE gmsritritdatum = '2026-01-01'")


gms_edaz_tasks |> filter(task_id == "4") |> select(task_id, receive_task_datetime_edaz)
tasks |> filter(task_id == "4") |> pull(task_id, receive_task_datetime_edaz)
gms_for_edaz_merge |> filter(task_id == "4")


inner_join(
  tibble(task_id = c(4, 4), receive_task_date = c("2026-01-01", "2025-01-01")),
  tibble(task_id = c(4, 4), test = c("1", "2"))
)


tasks[, grepl("date", colnames(tasks))]

colnames(tasks)[grepl("date", colnames(tasks))]
colnames(gms_for_edaz_merge)[grepl("date", colnames(gms_for_edaz_merge))]


colnames(tasks)[grepl("year", colnames(tasks))]
colnames(gms_for_edaz_merge)[grepl("year", colnames(gms_for_edaz_merge))]

gms_for_edaz_merge[, grepl("date", colnames(gms_for_edaz_merge))]


"incident_id_edaz" = "incident_id_gms"


incident_id_gms_edaz = incident_id_gms


tasks$incident_id_drfrit_edaz[duplicated(tasks$incident_id_drfrit_edaz)]



tasks$receive_task_datetime_edaz

#start_incident_cpa_gms_datetime first_call_gms_datetime


tasks |> filter(task_id == 522) |> pull(call_datetime_edaz)
gms_for_edaz_merge |> filter(task_id == 522) |> pull(first_call_gms_datetime)

year(mdy_hms(call_datetime_gms_edaz))

#nrow(gms_edaz_tasks_test) / nrow(tasks) * 100 = 98.422
gms_edaz_tasks_test <-
  inner_join(
    tasks %>% filter(!is.na(task_id)),
    gms_for_edaz_merge,
    by = c("task_id", "call_year_gms_edaz" = "first_call_gms_year")
  ) %>% 
  mutate(source = "gms_edaz") 

#nrow(gms_edaz_tasks_test_2025) / nrow(tasks) * 100 = 95.267
gms_edaz_tasks_test_2025 <-
  inner_join(
    tasks %>% filter(!is.na(task_id), call_datetime_gms_edaz |> mdy_hms() |> year() == 2025),
    gms_for_edaz_merge |> filter(first_call_gms_datetime |> year() == 2025),
    by = c("task_id")
  ) %>% 
  mutate(source = "gms_edaz") 

gms_edaz_tasks_test2 <-
  inner_join(
    tasks %>% filter(!is.na(task_id)),
    gms_for_edaz_merge,
    by = c("task_id"),
    multiple = "first"
  ) %>% 
  mutate(source = "gms_edaz") 


parse <- import("Library/preparation/parse.R")


tasks |> mutate(call_datetime_gms_edaz = as.POSIXct(call_datetime_gms_edaz, format = "%m/%d/%Y %I:%M:%S %p", tz = "CET"))



gms_for_edaz_merge$first_call_gms_datetime



first_call_gms_datetime

colnames(tasks)[grepl("call", colnames(tasks))]

#"start_incident_cpa_gms_datetime" "first_call_gms_datetime"
colnames(gms_for_edaz_merge)[grepl("date", colnames(gms_for_edaz_merge))]

gms_test <- gms_for_edaz_merge |> select(task_id, start_incident_cpa_gms_datetime, first_call_gms_datetime, transport_time_gms)
gms_test[as.integer(gms_test$task_id) <= 10, ] |> arrange(as.integer(task_id))
#call_datetime_gms_edaz

tasks_test <- tasks[as.integer(tasks$task_id) <= 10, ] |> select(task_id, call_datetime_gms_edaz) |> arrange(task_id) |> View()

gms_for_edaz_merge$start_incident_cpa_gms_datetime

gms_for_edaz_merge$first_call_gms_datetime
tasks$call_datetime_gms_edaz


tasks$call_datetime_gms_edaz |> year()

test_tibble <- tibble(tasks_call_datetime = tasks |> filter(as.integer(task_id) < 10, call_datetime_gms_edaz |> mdy_hms() |> year() == 2026) |> arrange(task_id) |> pull(call_datetime_gms_edaz),
                      merge_first_call = gms_for_edaz_merge |> filter(as.integer(task_id) < 10, first_call_gms_datetime |> year() == 2026) |> arrange(task_id) |> pull(first_call_gms_datetime),
                      # merge_start_incident = gms_for_edaz_merge |> filter(as.integer(task_id) < 10, start_incident_cpa_gms_datetime |> year() == 2026) |> arrange(task_id) |> pull(start_incident_cpa_gms_datetime))


tasks_call_datetime = tasks |> filter(as.integer(task_id) < 10, call_datetime_gms_edaz |> mdy_hms() |> year() == 2026) |> arrange(task_id) |> pull(call_datetime_gms_edaz, task_id)
merge_first_call = gms_for_edaz_merge |> filter(as.integer(task_id) < 10, first_call_gms_datetime |> year() == 2026) |> arrange(task_id) |> pull(first_call_gms_datetime, task_id)
# merge_start_incident = gms_for_edaz_merge |> filter(as.integer(task_id) < 10, start_incident_cpa_gms_datetime |> year() == 2026) |> arrange(task_id) |> pull(start_incident_cpa_gms_datetime, task_id)
