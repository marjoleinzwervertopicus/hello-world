source("Library/init.R")
database <- import("Library/database/database.R")

connections <- database$get_connections("rav_drenthe")

connections$customer$get("SELECT DISTINCT(jsonb_array_elements_text(errors)) FROM ambulance_task_edaz")


connections$customer$get("SELECT DISTINCT(jsonb_array_elements_text(specialisme_devise)) FROM roaz_rav")
connections$customer$get("SELECT DISTINCT(jsonb_array_elements_text(specialisme_devise)) FROM roaz_rav_inprogress")

connections <- database$get_connections("roaz_aznn")


connections <- database$get_connections("etl.rav_drenthe")

connections$customer$get("SELECT * FROM logistics_inbox")

connections <- database$get_connections("rav_limburg_zuid")
connections <- database$get_connections("rav_limburg_noord")
connections <- database$get_connections("mk_limburg")


connections <- database$get_connections("rav_fryslan")
connections <- database$get_connections("kwaliteitskaderapp")
connections <- database$get_connections("lazk")
connections <- database$get_connections("mknn")



connections$customer$get("SELECT indexname, indexdef
                         FROM pg_indexes
                         WHERE tablename = 'dispatch_task_gms';")


connections <- database$get_connections("etl.mknn")

connections <- database$get_connections("devise")
connections <- database$get_connections("etl.rav_ijsselland")
connections <- database$get_connections("rav_ijsselland")

connections$customer$get("SELECT isdeleted FROM ambulance_task_edaz WHERE task_id = 999991")


connections$customer$get("UPDATE ambulance_task_edaz SET isdeleted = '0' WHERE task_id = 999991")


a <- connections$customer$get("SELECT approval.year, ambulance_task_edaz.receive_task_year, ambulance_task_edaz_id, ambulance_task_edaz.task_id as task_id, urgency, receive_task_datetime, leave_task_datetime, preparation_duration, response_duration, response_duration_delayed, driver_email, approval FROM ambulance_task_edaz left join approval ON ambulance_task_edaz.task_id = approval.task_id and approval.type in ('ambulance') WHERE ( ( a1_performance IN (TRUE) and preparation_duration > (60::float8) ) or ( a2_performance IN (TRUE) and preparation_duration > (60::float8) ) ) AND receive_task_datetime BETWEEN '2023-09-25' AND '2023-10-01 23:59:59'")
a %>% group_by(approval) %>% summarize(n = n())
b <- connections$customer$get("SELECT approval.year, ambulance_task_edaz.receive_task_year, ambulance_task_edaz_id, ambulance_task_edaz.task_id as task_id, urgency, receive_task_datetime, leave_task_datetime, preparation_duration, response_duration, response_duration_delayed, driver_email, approval FROM ambulance_task_edaz left join approval ON ambulance_task_edaz.task_id = approval.task_id and approval.type in ('ambulance') and approval.year = ambulance_task_edaz.receive_task_year WHERE ( ( a1_performance IN (TRUE) and preparation_duration > (60::float8) ) or ( a2_performance IN (TRUE) and preparation_duration > (60::float8) ) ) AND receive_task_datetime BETWEEN '2023-09-25' AND '2023-10-01 23:59:59'")
b %>% group_by(approval) %>% summarize(n = n())
c <- setdiff(a, b)
d <- setdiff(b, a)

identical(c %>% select(-year, -approval), d %>% select(-year, -approval))

connections$customer$get("SELECT * FROM approval")
connections$customer$set("INSERT INTO approval VALUES approval_id = 9999 task_id = 9999999, type = 'ambulance', year = 2023, ts = '2023-01-01'")

connections$customer$get("SELECT * FROM statussen LIMIT 10")
a <- connections$customer$get("SELECT * FROM user_info")

a <- connections$customer$get("select u.email as email, u.provider_id as provider_id, u.admin as admin, p.type as provider_type, p.region as region, p.name as name from user_info u left join provider p on u.provider_id = p.provider_id")

a %>% filter(!is.na(provider_type) & provider_type != "ROAZ-coördinator") %>% View()

a <- connections$customer$get("SELECT * FROM user_info")

a <- connections$customer$get('SELECT count(*) as y, deployment_centralist_user_email FROM gms_task WHERE ((needs_approval IN (TRUE) and call_part_2_duration_delayed IN (TRUE)) and exclude IN (FALSE) ) GROUP BY "deployment_centralist_user_email"')



connections$customer$get("SELECT min(gmsritritdatum) FROM edaz_task_all_inbox")
a <- connections$customer$get("SELECT COUNT(*) FROM edaz_task_raw")

a <- connections$customer$get("SELECT * FROM edaz_task_raw LIMIT 1")

connections$customer$get("INSERT INTO user_info (user_id, name, email) VALUES (1, 'Peter', 'peter@meetdevise.nl');")


connections$customer$get("SELECT * FROM insight") %>% View()

connections$customer$get("SELECT * FROM insight WHERE owner_id = 1") %>% View()


connections$customer$set("UPDATE insight SET owner_id = 2 WHERE owner_id = 57")



connections$customer$get("SELECT * FROM user_info")

connections <- database$get_connections("keycloak_db")

connections$customer$get("SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';")

connections$customer$get("select driver_email from ambulance_task_edaz group by driver_email")$driver_email

connections$customer$get("SELECT max(ts) FROM personnel_contract")

connections$customer$get("SELECT MAX(ts) FROM edaz_valid_task_all_inbox")


connections$customer$set("CREATE INDEX idx_dispatch_task_gms_ ON dispatch_task_gms (urgency_dispatcher, provider_name, exclude, receive_task_datetime);")



connections$customer$get("SELECT * FROM information_schema.columns 
                   WHERE table_name = 'psycholance' 
                   ORDER BY ordinal_position")

connections$customer$get("SELECT
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    schemaname = 'public' AND tablename = 'dispatch_task_gms'")


connections$customer$get("SELECT * FROM user_info")

a <- connections$customer$get("SELECT * FROM slack_error")

connections$customer$get("SELECT * FROM user_info")

connections$customer$get("SELECT * FROM insight")
connections$customer$get("SELECT * FROM simulation")

connections$customer$get("SELECT * from insight WHERE insight_id = 3671")


connections <- database$get_connections(c("rav_drenthe", "rav_fryslan", "mmt_umcg"))


connections$rav_drenthe$get("SELECT last_edited FROM user_info WHERE email = 'marjolein@deviseanalytics.com'")
connections$rav_fryslan$get("SELECT last_edited FROM user_info WHERE email = 'marjolein@deviseanalytics.com'")
connections$mmt_umcg$get("SELECT last_edited FROM user_info WHERE email = 'marjolein@deviseanalytics.com'")




connections$etl.mk_limburg$get("SELECT ts FROM v_a_art_patient ORDER BY ts DESC LIMIT 10 ")
a <- connections$customer$get("SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';")
"disease" %in% colnames(a)
"specialisme" %in% colnames(a)

a <- connections$customer$get("SELECT * FROM ambulance_task_edaz LIMIT 1")

connections <- database$get_connections("rav_fryslan")

test <- connections$customer$get("SELECT * FROM personnel_hours")
test <- connections$customer$get("SELECT SUM(value) as y, prop_name FROM personnel_hours WHERE ( cat_internal_employee IN (TRUE) and account_name IN ('Operationeel') ) GROUP BY 'prop_name'")
test <- connections$customer$get("SELECT SUM(value) as y, prop_name FROM personnel_hours WHERE (cat_internal_employee IN (TRUE) ) GROUP BY prop_name")




data_sources <- import("Library/calculate/data_sources.R")

data <- data_sources$connect(list(tracks = paste0("db ", "rav_fryslan", " ambulance_track_webfleet"), tasks = "db rav_fryslan ambulance_task_edaz"))
a <- data$tasks$select()
a <- data$tasks$select(filters = list(task_id = NA))


connections$customer$get("SELECT * FROM user_info WHERE email = 'marjolein@deviseanalytics.com'")
connections$customer$get("UPDATE user_info SET devise = '1' WHERE email = 'marjolein@deviseanalytics.com'")


connections$customer$get("SELECT * FROM ambulance_task_edaz WHERE ( specialisme IN ('orthopedie') and exclude IN ('FALSE')) AND receive_task_datetime BETWEEN '2023-01-01' AND '2023-01-31 23:59:59' limit 10")


connections$customer$set("UPDATE user_info SET uid = ?uid WHERE email = ?email", list(uid = "test", email = "r.vandiepen@rav.nl"))
