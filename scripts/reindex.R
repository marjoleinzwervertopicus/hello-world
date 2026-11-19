library(db)
Sys.setenv("DEVISE_DB_USER" = "postgres")

connections <- db_connect("mknn", preset = "postgres_application_server")


# connections$query("SELECT c.relname,
# pg_size_pretty(pg_relation_size(c.oid))       AS heap,
# pg_size_pretty(pg_indexes_size(c.oid))        AS indexes,
# pg_size_pretty(pg_total_relation_size(c.oid)) AS total,
# s.n_live_tup, s.n_dead_tup
# FROM pg_class c
# JOIN pg_stat_user_tables s ON s.relid = c.oid
# ORDER BY pg_total_relation_size(c.oid) DESC
# LIMIT 20;")


connections$query("REINDEX INDEX idx_dispatch_task_gms_incident_description;", echo = T)
connections$disconnect()


