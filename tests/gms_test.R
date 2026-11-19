library(db)
connections <- db_connect("shared", preset = "postgres_development_server")
connections$query("SELECT COUNT(*) FROM raw.arc_incident")
connections$query("SELECT MAX(ts) FROM raw.arc_incident")

connections$disconnect()


library(db)
connections <- db_connect("mknn", preset = "postgres_etl_server")
connections$query("SELECT COUNT(*) FROM raw.arc_incident")
connections$query("SELECT MAX(ts) FROM raw.arc_incident")
connections$disconnect()
