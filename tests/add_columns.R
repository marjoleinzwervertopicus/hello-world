roaz_ambulances$a1_performance <- c(rep(T, nrow(roaz_ambulances)/2), rep(F, nrow(roaz_ambulances)/2))
roaz_ambulances$response_duration_delayed <- c(rep(c(T, F), nrow(roaz_ambulances)/2))
connection$set("ALTER TABLE roaz_ambulances ADD COLUMN a1_performance boolean")
connection$set("ALTER TABLE roaz_ambulances ADD COLUMN response_duration_delayed boolean")

connection$insert_table_unsafe("roaz_ambulances", roaz_ambulances)
